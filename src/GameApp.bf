using ari;
using bh.game;

namespace bh
{
	public class GameApp: Application
	{
		World world = new World();
		RenderSystem2D render_system = new RenderSystem2D();
		SceneSystem2D scene_system = new SceneSystem2D();

		public this()
		{
			setup = new GfxSetup();
			setup.window.Width = 320;
			setup.window.Height = 640;
		}

		public override void OnInit()
		{
			base.OnInit();
			world.AddSystem(render_system);
			world.AddSystem(scene_system);
		}

		public override void OnFrame(float _elapsedTime)
		{
			base.OnFrame(_elapsedTime);
			world.Update(_elapsedTime);
		}

		public override void OnEvent(ari_event* _event, ref WindowHandle _handle)
		{
			base.OnEvent(_event, ref _handle);
		}

		public override void OnCleanup()
		{
			base.OnCleanup();
			delete world;
			delete render_system;
			delete scene_system;
		}
	}
}
