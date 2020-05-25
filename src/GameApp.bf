using ari;
using bh.game;
using System;

namespace bh
{
	public class GameApp: Application
	{
		// Engine stuff
		World world = new World();
		RenderSystem2D render_system = new RenderSystem2D();
		SceneSystem2D scene_system = new SceneSystem2D();
		FileSystemLocal _fs = new FileSystemLocal();

		// Game stuff
		Map map = new Map();

		public this()
		{
			setup = new GfxSetup();
			setup.window.Width = 320;
			setup.window.Height = 640;
			setup.window.HighDpi = true;
			// warning: Don't initialize anything here use OnInit function.
		}

		public override void OnInit()
		{
			base.OnInit();
			world.AddSystem(render_system);
			world.AddSystem(scene_system);

			Io.RegisterFileSystem("file", _fs);

			// Game stuff
			map.Init(world);
		}

		public override void OnFrame(float _elapsedTime)
		{
			base.OnFrame(_elapsedTime);
			map.Update(_elapsedTime);
			world.Update(_elapsedTime);
		}

		public override void OnEvent(ari_event* _event, ref WindowHandle _handle)
		{
			base.OnEvent(_event, ref _handle);
			if (_event.type == .ARI_EVENTTYPE_KEY_DOWN)
			{
				if (_event.key_code == .ARI_KEYCODE_UP)
					map.HandleInput(.RotateCW);
				if (_event.key_code == .ARI_KEYCODE_LEFT)
					map.HandleInput(.Left);
				if (_event.key_code == .ARI_KEYCODE_RIGHT)
					map.HandleInput(.Right);
				if (_event.key_code == .ARI_KEYCODE_DOWN)
					map.HandleInput(.Down);
				if (_event.key_code == .ARI_KEYCODE_SPACE)
					map.HandleInput(.Drop);
			}
		}

		public override void OnCleanup()
		{
			base.OnCleanup();
			delete world;
			delete render_system;
			delete scene_system;
			delete _fs;

			delete map;
		}
	}
}
