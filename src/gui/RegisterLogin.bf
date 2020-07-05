using ari.gui;
using imgui_beef;

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
				ImGui.Button("Login");
				ImGui.SameLine(0, 100);
				ImGui.Button("Register");
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
