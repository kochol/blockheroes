using ari;
using ari.gui;
using ari.user;
using ari.net;
using ari.biz;
using bh.game;
using System;
using System.Collections;
using bh.net;
using bh.gui;
using curl;

namespace bh
{
	public class GameApp: Application
	{
		// Engine stuffs
		World world = new World();
		public Entity GameEntity;
		RenderSystem2D render_system = new RenderSystem2D();
		SceneSystem2D scene_system = new SceneSystem2D();
		GuiSystem gui_system = new GuiSystem();
		FileSystemLocal _fs = new FileSystemLocal();
		float touch_x;
		float touch_y;
		float total_time = 0;
		float touch_start_time;
		bool MovedWithTouch;
		bool MovedDownWithTouch;

		// Canvas size
		public static readonly int32 CanvasWidth = 458;

		// Analytics
		public static GoogleAnalytics Analytics = null;
		public static uint64 MultiTime;

		// network
#if ARI_SERVER
		ServerSystem network = new ServerSystem();
#else
		ClientSystem network = new ClientSystem();
#endif
		NetworkManager netManager;
		public static String IP = "104.244.75.183";//"127.0.0.1";//
		public static int32 Port = 55223;
		public static String Token = null ~ delete _;
		public static int64 LobbyId = 0;

		// Profile server: The world will delete this on exit
		public static ProfileSystem profile_system = null;

		// Game stuff
		MainMenu main_menu;
		InGameMenu in_game_menu;

		public this()
		{
			setup = new GfxSetup();
			setup.window.Width = CanvasWidth * 2;
			setup.window.Height = 640;
			setup.window.HighDpi = true;
			setup.swap_interval = 1;
			// warning: Don't initialize anything here use OnInit function.
		}

		public override void OnInit()
		{
			base.OnInit();

			// Set clear color
			Color clear_color = .(72, 78, 112, 255);
			Gfx.SetClearColor(ref clear_color);

			// Add systems
			world.AddSystem(render_system);
			world.AddSystem(scene_system);
			world.AddSystem(network);
			render_system.AddChild(world, gui_system);

			// Initialize network
			Net.InitNetwork();
#if ARI_SERVER
			network.CreateServer(IP, Port);
#endif

			netManager = new NetworkManager(network, world);

			Io.RegisterFileSystem("file", _fs);

			// Profile server
			HttpClientService http = new HttpClientService();
			world.AddSystem(http);

			profile_system = new ProfileSystem("https://blockheroesgame.com/api/", http);
			profile_system.OnLoggedIn = new => OnLoggedIn;
			profile_system.OnLoginFailed = new => OnLogginFailed;
			profile_system.OnPlayerData = new => OnPlayerData;
			profile_system.OnJoinedLobby = new => OnJoinedLobby;
#if ARI_SERVER
			if (Token != null)
			{
				profile_system.Login(Token);
			}
#else			
			profile_system.Login();
#endif
			world.AddSystem(profile_system);

			// Game stuff
			GameEntity = World.CreateEntity();

			// main menu
			main_menu = new MainMenu();
			main_menu.OnSinglePlayerClick = new => OnSinglePlayerClicked;
			main_menu.OnMultiPlayerClick = new => OnMultiPlayerClicked;
			world.AddComponent(GameEntity, main_menu);

			// in game gui
			in_game_menu = new InGameMenu();
			*in_game_menu.Visible = false;
			in_game_menu.ShowReset = &netManager.[Friend] single_player;
			in_game_menu.OnResetClick = new () => { // On reset click
				netManager.ResetGame();
				*in_game_menu.Visible = false;
				if (Analytics != null)
				{
					Analytics.Event("GUI", "Reset");
				}
			};
			in_game_menu.OnExitClick = new () => { // On exit click
				netManager.Exit();
				*main_menu.Visible = true;
				*in_game_menu.Visible = false;
				if (Analytics != null)
				{
					Analytics.TrackScreenView("MainMenu");
				}
			};
			world.AddComponent(GameEntity, in_game_menu);

			world.AddEntity(GameEntity);
		}

		public override void OnFrame(float _elapsedTime)
		{
			total_time += _elapsedTime;
			base.OnFrame(_elapsedTime);
			netManager.Update(_elapsedTime);
			world.Update(_elapsedTime);
		}

		// handle keyboard and touch events
		public override void OnEvent(ari_event* _event, ref WindowHandle _handle)
		{
			base.OnEvent(_event, ref _handle);
			world.Emit(_event, ref _handle);

			//bool isguiactive = imgui_beef.ImGui.IsAnyItemActive();

			if (_event.type == .ARI_EVENTTYPE_KEY_DOWN)
			{
				if (_event.key_code == .ARI_KEYCODE_UP)
					netManager.HandleInput(.RotateCW);
				if (_event.key_code == .ARI_KEYCODE_LEFT)
					netManager.HandleInput(.Left);
				if (_event.key_code == .ARI_KEYCODE_RIGHT)
					netManager.HandleInput(.Right);
				if (_event.key_code == .ARI_KEYCODE_DOWN)
					netManager.HandleInput(.Down);
				if (_event.key_code == .ARI_KEYCODE_SPACE && !_event.key_repeat)
					netManager.HandleInput(.Drop);
				if (netManager.game_started && _event.key_code == .ARI_KEYCODE_ESCAPE && !_event.key_repeat)
				{
					// Show in game menu
					*in_game_menu.Visible = !*in_game_menu.Visible;
					netManager.GamePaused = *in_game_menu.Visible;
				}
			}
			else if (_event.type == .ARI_EVENTTYPE_TOUCHES_BEGAN)
			{
				touch_x = _event.touches[0].pos_x;
				touch_y = _event.touches[0].pos_y;
				MovedWithTouch = false;
				MovedDownWithTouch = false;
				touch_start_time = total_time;
			}
			else if (_event.type == .ARI_EVENTTYPE_TOUCHES_MOVED)
			{
				float dx = touch_x - _event.touches[0].pos_x;
				int w = _event.window_width / 15;
				if (dx > w)
				{
					touch_x = _event.touches[0].pos_x;
					netManager.HandleInput(.Left);
					MovedWithTouch = true;
				}
				else if (dx < -w)
				{
					touch_x = _event.touches[0].pos_x;
					netManager.HandleInput(.Right);
					MovedWithTouch = true;
				}
				else if (!MovedWithTouch && total_time - touch_start_time > 0.4f)
				{
					MovedDownWithTouch = true;
					netManager.HandleInput(.Down);
				}
			}
			else if (_event.type == .ARI_EVENTTYPE_TOUCHES_ENDED)
			{
				if (MovedWithTouch)
					return;
				float dx = touch_x - _event.touches[0].pos_x;
				float dy = touch_y - _event.touches[0].pos_y;
				if (dy < -200 && Math.Abs(dx) < 64)
					netManager.HandleInput(.Drop);
				else if (!MovedDownWithTouch && Math.Abs(dx) < 32)
					netManager.HandleInput(.RotateCW);
			}
		}

		void OnSinglePlayerClicked()
		{
			*main_menu.Visible = false;
			netManager.StartSinglePlayer();
			if (Analytics != null)
			{
				Analytics.TrackScreenView("SinglePlayer");
				Analytics.Event("GUI", "SinglePlayer");
			}
		}

		void OnJoinedLobby(Lobby lobby)
		{
#if !ARI_SERVER
			network.Connect(lobby.serverIp, lobby.serverPort);
			delete lobby;
#endif
			if (Analytics != null)
			{
				Analytics.TrackScreenView("MultiPlayer");
				Analytics.Timing("Lobby", "Found", (int32)Timer.ToMilliSeconds(Timer.Since(MultiTime)));
			}
			*main_menu.Visible = false;
			main_menu.Status = .LoggedIn;
		}

		void OnMultiPlayerClicked()
		{
			MultiTime =	Timer.Now();
			if (Analytics != null)
			{
				Analytics.Event("GUI", "MultiPlayer");
			}
			profile_system.AutoJoinToLobby();
			main_menu.Status = .FindingLobby;
			return;
		}

		void OnLoggedIn()
		{
			profile_system.GetPlayerData();
		}

		void OnLogginFailed(Easy.ReturnCode err)
		{
			Console.WriteLine(err);
			main_menu.Status = .LogginFailed;

			// Create Analytics
			if (Analytics == null)
			{
				HttpClientService http = new HttpClientService();
				world.AddSystem(http);
				Analytics = new GoogleAnalytics("UA-66345235-4", "Block heroes", "0.2", null , http);
				Analytics.TrackScreenView("MainMenu");
			}
			Analytics.Event("ProfileServer", "Login", "Failed");
		}

		void OnPlayerData(Player player)
		{
			Console.WriteLine("Welcome {}", player.userName);

			// Create Analytics
			if (Analytics == null)
			{
				HttpClientService http = new HttpClientService();
				world.AddSystem(http);
				Analytics = new GoogleAnalytics("UA-66345235-4", "Block heroes", "0.2", player.userName , http);
				Analytics.TrackScreenView("MainMenu");
			}
			else
			{
				var pid = new String();
				player.id.ToString(pid);
				delete Analytics.[Friend]m_sPlayerID;
				Analytics.[Friend]m_sPlayerID = pid;
			}
	
			delete player;
			if (main_menu != null)
				main_menu.Status = .LoggedIn;
		}

		public override void OnCleanup()
		{
			base.OnCleanup();
			delete render_system;
			delete scene_system;
			delete gui_system;
			delete _fs;
			world.RemoveComponent(GameEntity, main_menu, true);
			world.RemoveComponent(GameEntity, in_game_menu, true);

			delete GameEntity;

			delete netManager;

			if (Analytics != null)
			{
				Analytics.EndSession();
				delete Analytics;
				Analytics = null;
			}

			network.Stop();
			delete network;
			Net.ShutdownNetwork();
			delete world;
		}
	}
}
