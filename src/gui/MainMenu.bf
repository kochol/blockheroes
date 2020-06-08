using ari;
using System;

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

		bool ButtonClicked(ari_event* _event, Sprite2D _btn)
		{
			// Check for click
			int32 sx = _event.window_width / 2 - (int32)_btn.Scale.x / 2 - (int32)_btn.Position.x;
			int32 sy = _event.window_height / 2 - (int32)_btn.Scale.y / 2 - (int32)_btn.Position.y;
			int32 ex = sx + (int32)_btn.Scale.x;
			int32 ey = sy + (int32)_btn.Scale.y;

			if (_event.type == .ARI_EVENTTYPE_MOUSE_UP)
			{
				if (_event.mouse_x < ex && _event.mouse_x > sx &&
					_event.mouse_y < ey && _event.mouse_y > sy)
				{
					return true;
				}
			}
			else
			{
				
				if (_event.touches[0].pos_x < ex && _event.touches[0].pos_x > sx &&
					_event.touches[0].pos_y < ey && _event.touches[0].pos_y > sy)
				{
					return true;
				}
			}

			return false;
		}

		public void OnEvent(ari_event* _event)
		{
			if (_event.type != .ARI_EVENTTYPE_MOUSE_UP && _event.type != .ARI_EVENTTYPE_TOUCHES_ENDED)
				return;

			if (ButtonClicked(_event, sp_single_player))
				Console.WriteLine("Single player button clicked");
			else if (ButtonClicked(_event, sp_multi_player))
				Console.WriteLine("Multi player button clicked");
		}
	}
}
