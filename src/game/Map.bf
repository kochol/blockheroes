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
		Block active_block;
		float time = 0;
		float key_time = 0;
		KeyType last_key = .Drop;
		const float UpdateTime = 0.5f;
		const float KeyUpdateDelay = 0.1f;

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
			camera.Position.x = -160;
			camera.Position.y = -320;
			map_entity = World.CreateEntity();
			world.AddComponent(map_entity, camera);
		}

		public void Update(float _elasped_time)
		{
			if (state == .NeedNewBlock)
			{
				active_block = World.CreateEntity<Block>();
				active_block.Init(world, .L, Vector2(5, 18));
				blocks.Add(active_block);
				state = .BlockIsDropping;
				time = 0;
				return;
			}

			time += _elasped_time;
			key_time += _elasped_time;
			if (time < UpdateTime)
				return;
			time = 0;

			// drop the block
			active_block.HandleInput(.Down);
		}

		public void HandleInput(KeyType _key)
		{
			if (key_time < KeyUpdateDelay && last_key == _key)
				return;
			key_time = 0;
			if (_key == .Down)
				time = 0;
			last_key = _key;

			active_block.HandleInput(_key);
		}
	}
}
