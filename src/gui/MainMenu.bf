using ari;
using System;
using ari.gui;
using imgui_beef;

namespace bh.gui
{
	public class MainMenu: ScriptGui
	{
		public static TextureHandle tex_Buttons = .();

		public delegate void OnButtonClickDelegate();
		public OnButtonClickDelegate OnSinglePlayerClick = null ~ delete _;
		public OnButtonClickDelegate OnMultiPlayerClick = null ~ delete _;

		public this()
		{
			if (tex_Buttons.Handle == uint32.MaxValue)
			{
				tex_Buttons = Gfx.LoadTexture("res:menu.png");
			}
		}

		protected override bool BeginRender()
		{
			// Create window
			WindowHandle wh;
			wh.Handle = wh.Index = 0;
			int32 w, h;
			Io.GetWindowSize(ref wh, out w, out h);
			ImGui.SetNextWindowPos(.(w/2, h/2), .Always, .(0.5f, 0.5f));
			if (ImGui.Begin("MainMenu", null, .NoDecoration | .NoBackground | .AlwaysAutoResize))
			{
				// Single player button
				ImGui.ImageButton((void*)(uint)tex_Buttons.Index, .(216, 79), .(0.0390625f, 0.015625f), .(0.0390625f + 0.421875f, 0.015625f + 0.154296f)
					, -1, .(0,0,0,0));
	
				// Multi player button
				ImGui.ImageButton((void*)(uint)tex_Buttons.Index, .(214, 82), .(0.0234375f, 0.80078125f), .(0.0234375f + 0.41796875f, 0.80078125f + 0.16015625f));

				return true;
			}
			return false;
		}

		protected override void EndRender()
		{
			ImGui.End();
		}
	}
}
