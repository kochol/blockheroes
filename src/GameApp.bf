using ari;
using ari.gui;
using ari.user;
using ari.net;
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
		bool delete_main_menu = false;

		public this()
		{
			setup = new GfxSetup();
			setup.window.Width = 660;
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

			profile_system = new ProfileSystem("https://localhost:44327/api/", http);
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

			main_menu = new MainMenu();
			main_menu.OnSinglePlayerClick = new => OnSinglePlayerClicked;
			main_menu.OnMultiPlayerClick = new => OnMultiPlayerClicked;

			world.AddComponent(GameEntity, main_menu);
			world.AddEntity(GameEntity);
		}

		public override void OnFrame(float _elapsedTime)
		{
			total_time += _elapsedTime;
			base.OnFrame(_elapsedTime);
			if (delete_main_menu)
			{
				DeleteMainMenu();
			}
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
				if (_event.key_code == .ARI_KEYCODE_SPACE)
					netManager.HandleInput(.Drop);
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
			delete_main_menu = true;

			netManager.StartSinglePlayer();
		}

		void OnJoinedLobby(Lobby lobby)
		{
#if !ARI_SERVER
			network.Connect(lobby.serverIp, lobby.serverPort);
			delete lobby;
#endif
			delete_main_menu = true;
		}

		void OnMultiPlayerClicked()
		{
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
		}

		void OnPlayerData(Player player)
		{
			Console.WriteLine("Welcome {}", player.userName);
			delete player;
			if (main_menu != null)
				main_menu.Status = .LoggedIn;
		}

		void DeleteMainMenu()
		{
			delete_main_menu = false;
			if (main_menu != null)
			{
				world.RemoveComponent(GameEntity, main_menu, true);
				main_menu = null;
			}
		}

		public override void OnCleanup()
		{
			base.OnCleanup();
			delete render_system;
			delete scene_system;
			delete gui_system;
			delete _fs;
			if (main_menu != null)
			{
				world.RemoveComponent(GameEntity, main_menu, true);
				main_menu = null;
			}

			delete GameEntity;

			delete netManager;

			network.Stop();
			delete network;
			Net.ShutdownNetwork();
			delete world;
		}
	}
}
