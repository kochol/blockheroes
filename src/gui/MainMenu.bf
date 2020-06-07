using ari;

namespace bh.gui
{
	public class MainMenu: Entity
	{
		static TextureHandle tex_Buttons = .();
		Sprite2D sp_single_player = null ~ delete _;
		Sprite2D sp_multi_player = null ~ delete _;
		Camera2D camera = null ~ delete _;

		protected this(EntityHandle _handle): base(_handle)
		{
			if (tex_Buttons.Handle == uint32.MaxValue)
			{
				tex_Buttons = Gfx.LoadTexture("res:menu.jpg");
			}
		}

		public void Init(World world)
		{
			// Single player button
			sp_single_player = World.CreateSprite2D();
			*sp_single_player.Texture = tex_Buttons;
			sp_single_player.UV.Set(0.0390625f, 0.015625f, 0.421875f, 0.154296f);
			sp_single_player.Scale.Set(216, 79);
			sp_single_player.Position.Set(0, 39);
			world.AddComponent(this, sp_single_player);

			// Multi player button
			sp_multi_player = World.CreateSprite2D();
			*sp_multi_player.Texture = tex_Buttons;
			sp_multi_player.UV.Set(0.0234375f, 0.80078125f, 0.41796875f, 0.16015625f);
			sp_multi_player.Scale.Set(214, 82);
			sp_multi_player.Position.Set(0, -41);
			world.AddComponent(this, sp_multi_player);

			// camera
			camera = World.CreateCamera2D();
			world.AddComponent(this, camera);

			// Add entity
			world.AddEntity(this);
		}
	}
}
