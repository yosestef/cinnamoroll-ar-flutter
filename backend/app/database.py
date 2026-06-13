import aiosqlite
import os

DB_PATH = os.getenv("DB_PATH", "ar_sessions.db")

async def init_db():
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute('''
            CREATE TABLE IF NOT EXISTS ar_sessions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                plane_type TEXT NOT NULL,
                placed_successfully INTEGER NOT NULL,
                timestamp TEXT NOT NULL,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        await db.commit()

async def log_session(plane_type: str, placed_successfully: int, timestamp: str):
    async with aiosqlite.connect(DB_PATH) as db:
        cursor = await db.execute(
            "INSERT INTO ar_sessions (plane_type, placed_successfully, timestamp) VALUES (?, ?, ?)",
            (plane_type, placed_successfully, timestamp)
        )
        await db.commit()
        return cursor.lastrowid
