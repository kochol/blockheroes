using ari.gui;
using imgui_beef;
using System;

namespace bh.gui
{
	class RegisterLogin: ScriptGui
	{
		public bool IsOpen = true;
		bool CallEnd;
		String UserName = new String(40) ~ delete _;
		String Password = new String(40) ~ delete _;

		protected override bool BeginRender()
		{
			CallEnd = IsOpen;
			if (IsOpen && ImGui.Begin("RegisterLogin", &IsOpen))
			{
				ImGui.InputText("UserName", UserName, 40);
				ImGui.InputText("PassWord", Password, 40, .Password);
				if (ImGui.Button("Login"))
				{
					GameApp.profile_system.Login(UserName, Password);
				}
				ImGui.SameLine(0, 100);
				if (ImGui.Button("Register"))
				{
					GameApp.profile_system.Register(UserName, Password);
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
