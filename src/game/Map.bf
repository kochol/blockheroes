using ari;
using System.Collections;

namespace bh.game
{
	public class Map
	{
		bool[,] data = new bool[10,20] ~ delete _;
		World world = null;
		Entity map_entity;
		Camera2D camera;
		List<Block> blocks = new List<Block>() ~ DeleteContainerAndItems!(_);

		enum GameState
		{
			NeedNewBlock,
			BlockIsDropping
		}

		GameState state = .NeedNewBlock;

		public ~this()
		{
			delete map_entity;
			delete camera;
		}

		public void Init(World _world)
		{
			world = _world;
			camera = World.CreateCamera2D();
			map_entity = World.CreateEntity();
			world.AddComponent(map_entity, camera);
		}

		public void Update(float _elasped_time)
		{
			if (state == .NeedNewBlock)
			{
				Block b = World.CreateEntity<Block>();
				b.Init(world, .Box);
				blocks.Add(b);
				state = .BlockIsDropping;
			}
		}
	}
}
