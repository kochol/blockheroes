using ari;
using System;
using ari.gui;
using imgui_beef;

namespace bh.gui
{
	delegate void OnButtonClickDelegate();

	public class MainMenu: ScriptGui
	{
		public static TextureHandle tex_Buttons = .();

		public OnButtonClickDelegate OnSinglePlayerClick = null ~ delete _;
		public OnButtonClickDelegate OnMultiPlayerClick = null ~ delete _;

		public enum MenuStatus
		{
			LoggingIn,
			LoggedIn,
			LogginFailed,
			FindingLobby
		}
		public MenuStatus Status = .LoggingIn;

		RegisterLogin login_form = null;

		public this()
		{
			if (tex_Buttons.Handle == uint32.MaxValue)
			{
				tex_Buttons = Gfx.LoadTexture("res:menu.png");
			}
		}

		public ~this()
		{
			if (login_form != null)
			{
				_world.RemoveComponent(Handle.Owner, login_form, true);
				login_form = null;
			}
		}

		protected override bool BeginRender()
		{
			// Create window
			WindowHandle wh;
			wh.Handle = wh.Index = 0;
			int32 w, h;
			Io.GetWindowSize(ref wh, out w, out h);
			ImGui.SetNextWindowPos(.(w/2, h/2 - 125), .Always, .(0.5f, 0.0f));
			if (ImGui.Begin("MainMenu", null, .NoDecoration | .NoBackground | .AlwaysAutoResize))
			{
				ImGui.PushStyleColor(.Button, 0);
				ImGui.PushStyleColor(.ButtonActive, 0);
				ImGui.PushStyleColor(.ButtonHovered, 0);

				// Single player button
				ImGui.PushID("single_player");
				if (ImGui.ImageButton((void*)(uint)tex_Buttons.Index, .(216, 79), .(0.0390625f, 0.015625f), .(0.0390625f + 0.421875f, 0.015625f + 0.154296f)))
				{
					if (OnSinglePlayerClick != null)
						OnSinglePlayerClick();
				}
				ImGui.PopID();
	
				// Multi player button
				ImGui.PushID("multi_player");
				if (Status == .LoggedIn)
				{
					if (ImGui.ImageButton((void*)(uint)tex_Buttons.Index, .(214, 82), .(0.0234375f, 0.80078125f), .(0.0234375f + 0.41796875f, 0.80078125f + 0.16015625f))
						&& OnMultiPlayerClick != null)
						OnMultiPlayerClick();
				}
				else
				{
					ImGui.Image((void*)(uint)tex_Buttons.Index, .(214, 82), .(0.0234375f, 0.80078125f), .(0.0234375f + 0.41796875f, 0.80078125f + 0.16015625f),
						.(0.2f, 0.2f, 0.2f, 1));
				}
				ImGui.PopID();

				ImGui.PopStyleColor(3);

				// Is searching for lobby
				if (Status == .FindingLobby)
				{
					ImGui.Text("Searching for opponent");
					if (ImGui.Button("Cancel"))
					{
						GameApp.profile_system.CancelAutoJoinToLobby();
						Status = .LoggedIn;
					}
				}

				if (Status == .LoggedIn && ImGui.Button("Test Login"))
				{
					if (login_form == null)
					{
						login_form = new RegisterLogin();
						_world.AddComponent(Handle.Owner, login_form);
					}
					else if (!login_form.IsOpen)
					{
						login_form.IsOpen = true;
					}
				}
				else if (Status == .LogginFailed)
				{
					// Show retry button
					ImGui.Text("Failed to connect to server");
					if (ImGui.Button("Retry"))
					{
						GameApp.profile_system.Login();
						Status = .LoggingIn;
					}
				}

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
