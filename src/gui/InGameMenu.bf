using ari;
using System;
using ari.gui;
using imgui_beef;
using ari.io;

namespace bh.gui
{
	class InGameMenu: ScriptGui
	{
		public OnButtonClickDelegate OnResetClick = null ~ delete _;
		public OnButtonClickDelegate OnExitClick = null ~ delete _;
		public bool* ShowReset;

		protected override bool BeginRender()
		{
			// Create window
			WindowHandle wh;
			wh.Handle = wh.Index = 0;
			int32 w, h;
			Io.GetWindowSize(ref wh, out w, out h);
			ImGui.SetNextWindowPos(.(w/2, h/2 - 125), .Always, .(0.5f, 0.0f));
			ImGui.SetNextWindowBgAlpha(0.4f);
			if (ImGui.Begin("MainMenu", null, .NoDecoration | .AlwaysAutoResize))
			{
				ImGui.PushStyleColor(.Button, 0);
				ImGui.PushStyleColor(.ButtonActive, 0);
				ImGui.PushStyleColor(.ButtonHovered, 0);

				// Restart button
				if (*ShowReset == true)
				{
					ImGui.PushID("restart");
					if (ImGui.ImageButton((void*)(uint)MainMenu.tex_Buttons.Index, .(216, 79), .(0.541015625f, 0.80859375f), .(0.962890625f, 0.962890625f)))
					{
						if (OnResetClick != null)
							OnResetClick();
					}
					ImGui.PopID();
				}
	
				// Exit button
				ImGui.PushID("exit");
				if (ImGui.ImageButton((void*)(uint)MainMenu.tex_Buttons.Index, .(213, 77), .(0.5546875f, 0.19921875f), .(0.970703125f, 0.349609375f))
					&& OnExitClick != null)
					OnExitClick();
				ImGui.PopID();

				ImGui.PopStyleColor(3);

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
