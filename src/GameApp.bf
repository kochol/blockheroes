using ari;
using bh.game;
using System;
using System.Collections;
using bh.net;
using bh.gui;

namespace bh
{
	public class GameApp: Application
	{
		// Engine stuffs
		World world = new World();
		RenderSystem2D render_system = new RenderSystem2D();
		SceneSystem2D scene_system = new SceneSystem2D();
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

		// Game stuff
		MainMenu main_menu;

		public this()
		{
			setup = new GfxSetup();
			setup.window.Width = 660;
			setup.window.Height = 640;
			setup.window.HighDpi = true;
			// warning: Don't initialize anything here use OnInit function.
		}

		public override void OnInit()
		{
			base.OnInit();

			// Add systems
			world.AddSystem(render_system);
			world.AddSystem(scene_system);
			world.AddSystem(network);

			// Initialize network
			Net.InitNetwork();
#if ARI_SERVER
			network.CreateServer("127.0.0.1", 55223);
#else
			network.Connect("127.0.0.1", 55223);
#endif
			netManager = new NetworkManager(network, world);

			Io.RegisterFileSystem("file", _fs);

			// Game stuff
			main_menu = World.CreateEntity<MainMenu>();
			main_menu.Init(world);
		}

		public override void OnFrame(float _elapsedTime)
		{
			total_time += _elapsedTime;
			base.OnFrame(_elapsedTime);
			netManager.Update(_elapsedTime);
			world.Update(_elapsedTime);
		}

		public override void OnEvent(ari_event* _event, ref WindowHandle _handle)
		{
			base.OnEvent(_event, ref _handle);
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

		public override void OnCleanup()
		{
			base.OnCleanup();
			delete render_system;
			delete scene_system;
			delete _fs;

			delete main_menu;

			delete netManager;

			network.Stop();
			delete network;
			Net.ShutdownNetwork();
			delete world;
		}
	}
}
