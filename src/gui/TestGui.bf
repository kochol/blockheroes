using ari.gui;
using imgui_beef;

namespace bh.gui
{
	class TestGui : ScriptGui
	{
		protected override bool BeginRender()
		{
			char8[20] buf = default; 
			ImGui.InputText("Username", &buf[0], 20);
			ImGui.InputText("Password", &buf[0], 20, .Password);
			ImGui.Button("Login");
			ImGui.Image((void*)(uint)MainMenu.tex_Buttons.Index, .(216, 79), .(0.0390625f, 0.015625f), .(0.421875f, 0.154296f)
				  );
			return false;
		}
	}
}
