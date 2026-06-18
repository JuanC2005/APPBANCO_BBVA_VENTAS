import asyncio

from supabase import Client, create_client

from app.core.config import settings

supabase: Client = create_client(settings.SUPABASE_URL, settings.SUPABASE_SERVICE_KEY)


def get_supabase() -> Client:
    return supabase


async def supabase_execute(query):
    return await asyncio.to_thread(query.execute)
