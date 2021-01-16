using System;
using ari.gui;
using imgui_beef;

namespace bh.gui
{
	class ReplayControl: ScriptGui
	{
		public bool IsOpen = true;
		bool CallEnd;
		float speed = 1;

		protected override bool BeginRender()
		{
			CallEnd = IsOpen;
			if (IsOpen)
			{
				ImGui.SetNextWindowSize(.(200, 34));
				ImGui.SetNextWindowPos(.(10, 10));
			}
			if (IsOpen && ImGui.Begin("Replay controls", &IsOpen, .NoDecoration))
			{
				if (ImGui.Button("||"))
				{
					speed = 0;
				}
				ImGui.SameLine();
				if (ImGui.Button("0.5X"))
				{
					speed = 0.5f;
				}
				ImGui.SameLine();
				if (ImGui.Button("1X"))
				{
					speed = 1;
				}
				ImGui.SameLine();
				if (ImGui.Button("2X"))
				{
					speed = 2;
				}
				ImGui.SameLine();
				if (ImGui.Button("3X"))
				{
					speed = 3;
				}
				ImGui.SameLine();
				if (ImGui.Button("4X"))
				{
					speed = 4;
				}

#if !ARI_SERVER
				GameApp.netManager.[Friend]network.SetReplaySpeed(speed);
#endif
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
