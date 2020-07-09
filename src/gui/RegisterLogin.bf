using ari.gui;
using imgui_beef;
using System;

namespace bh.gui
{
	class RegisterLogin: ScriptGui
	{
		public bool IsOpen = true;
		bool CallEnd;
		char8[40] UserName;
		char8[40] Password;

		protected override bool BeginRender()
		{
			CallEnd = IsOpen;
			if (IsOpen && ImGui.Begin("RegisterLogin", &IsOpen))
			{
				ImGui.InputText("UserName", &UserName[0], 40);
				ImGui.InputText("PassWord", &Password[0], 40, .Password);
				if (ImGui.Button("Login"))
				{
					String username = scope String();
					username.Reference(&UserName[0]);
					String password = scope String();
					password.Reference(&Password[0]);
					GameApp.profile_system.Login(username, password);
				}
				ImGui.SameLine(0, 100);
				if (ImGui.Button("Register"))
				{
					String username = scope String();
					username.Reference(&UserName[0]);
					String password = scope String();
					password.Reference(&Password[0]);
					GameApp.profile_system.Register(username, password);
				}
				return true;
			}
			return false;
		}

		protected override void EndRender()
		{
			if (CallEnd)
				ImGui.End();
		}
	}
}
