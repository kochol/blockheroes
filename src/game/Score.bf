using System;
using System.Collections;
using Atma;

namespace bh.game
{
	[Serializable]
	class Score
	{
		public List<int32> BlockCount = null ~ delete _;
		public List<int32> ClearedLines = null ~ delete _;
		public int32 ClearedLineCount;
		public int32 SendLineCount;

		public int TotalScore;

		public this()
		{
			BlockCount = new List<int32>(7);
			for (int i = 0; i < 7; i++)
				BlockCount.Add(0);
			ClearedLines = new List<int32>(4);
			for (int i = 0; i < 4; i++)
				ClearedLines.Add(0);
		}

		public this(bool DontInit)
		{
		}

		public void CalcScore()
		{
			TotalScore = 0;
			for (int i = 0; i < 7; i++)
				TotalScore += BlockCount[i];
			TotalScore += ClearedLineCount * 10;
			TotalScore += SendLineCount * 20;
		}
	}
}

namespace ari.user
{
	extension PlayerScore
	{
		public bh.game.Score Score = null ~ delete _;
	}
}