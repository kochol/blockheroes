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
		WindowHandle window_handle;

		enum GameState
		{
			NeedNewBlock,
			BlockIsDropping,
			GameOver
		}

		GameState state = .NeedNewBlock;

		public ~this()
		{
			delete map_entity;
			delete camera;
			delete active_block;
			for (int i = 0; i < 10; i++)
			{
				for (int j = 0; j < 20; j++)
				{
					delete data[i, j];
				}
			}
		}

		public void Init(World _world)
		{
			window_handle.Handle = 0;
			window_handle.Index = 0;
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
			world.AddEntity(map_entity);
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
			// scale the camera
			int w = 0; int h = 0;
			Io.GetWindowSize(ref window_handle, ref w, ref h);
			float sx = (float)w / 320.0f;
			float sy = (float)h / 640.0f;
			sx = Math.Min(sx, sy);
			camera.Scale.Set(sx);
			camera.Position.x = -160 * sx;
			camera.Position.y = -320 * sx;

			if (state == .NeedNewBlock)
			{
				if (active_block != null)
					delete active_block;

				BlockType bt = .Box;
				active_block = World.CreateEntity<Block>();
				active_block.Init(world, bt, Vector2(5, 18), this);
				state = .BlockIsDropping;
				return;
			}
		}

		public void HandleInput(KeyType _key)
		{
			if (state != .BlockIsDropping)
				return;

			active_block.HandleInput(_key);
		}

		void MoveBlocks(int y, bool down)
		{
			float dy = -Block.[Friend]BlockSize;

			for (int j = y; j < 20; j++)
			{
				for (int i = 0; i < 10; i++)
				{
					if (data[i, j] != null)
					{
						data[i, j].Position.y += dy;
						data[i, j - 1] = data[i, j];
						data[i, j] = null;
					}
				}
			}
		}

		public void BlockReachedToEnd()
		{
			for (int i = 0; i < 4; i++)
			{
				Vector2 p = active_block.[Friend]blocks[i] + active_block.[Friend]position;
				int x = int(p.x);
				int y = int(p.y);
				if (y >= 19)
				{
					state = .GameOver;
					return;
				}
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

						MoveBlocks(j + 1, true);
						j--;
					}
				}
			}
		}
	}
}
