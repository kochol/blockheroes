using ari;
using System.Collections;
using System;

namespace bh.game
{
	public class Map
	{
		Sprite2D[,] data = new Sprite2D[10,20] ~ delete _;
		World world = null;
		Entity map_entity;
		Camera2D camera;
		Block active_block = null;

		Random rnd = new Random();

		// time values
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
			delete rnd;
			delete active_block;
		}

		public void Init(World _world)
		{
			for (int i = 0; i < 10; i++)
			{
				for (int j = 0; j < 20; j++)
				{
					data[i, j] = null;
				}
			}
			world = _world;
			camera = World.CreateCamera2D();
			camera.Position.x = -160;
			camera.Position.y = -320;
			map_entity = World.CreateEntity();
			world.AddComponent(map_entity, camera);
		}

		public bool Collide(Vector2[] block_pos, Vector2 _pos)
		{
			for (int i = 0; i < 4; i++)
			{
				Vector2 p = block_pos[i] + _pos;
				int x = int(p.x);
				int y = int(p.y);
				if (x < 0 || x > 9 ||
					y < 0 || y > 19 ||
					data[x, y] != null)
					return true;
			}

			return false;
		}

		public void Update(float _elasped_time)
		{
			if (state == .NeedNewBlock)
			{
				if (active_block != null)
					delete active_block;

				BlockType bt = (BlockType)rnd.Next(7);
				active_block = World.CreateEntity<Block>();
				active_block.Init(world, bt, Vector2(5, 18), this);
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

		public void BlockReachedToEnd()
		{
			for (int i = 0; i < 4; i++)
			{
				Vector2 p = active_block.[Friend]blocks[i] + active_block.[Friend]position;
				int x = int(p.x);
				int y = int(p.y);
				data[x, y] = active_block.[Friend]sprites[i];
				world.RemoveComponent(active_block, active_block.[Friend]sprites[i], false);
				world.AddComponent(map_entity, data[x, y]);
				active_block.[Friend]sprites[i] = null;
			}
			state = .NeedNewBlock;

			// check for line clean up
			for (int j = 0; j < 20; j++)
			{
				for (int i = 0; i < 10; i++)
				{
					if (data[i, j] == null)
						break;
					if (i == 9)
					{
						// the line is full delete it
						for (int di = 0; di < 10; di++)
						{
							world.RemoveComponent(map_entity, data[di, j], true);
							data[di, j] = null;
						}
					}
				}
			}
		}
	}
}
