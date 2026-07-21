from django.db import connection
from django.http import HttpResponse
from django.urls import path


def index(_request):
    db_name = connection.settings_dict.get("NAME", "unknown")

    try:
        # Force a DB call so the app validates PostgreSQL connectivity at runtime.
        with connection.cursor() as cursor:
            cursor.execute("SELECT current_database();")
            row = cursor.fetchone()
            if row and row[0]:
                db_name = row[0]
    except Exception:
        pass

    return HttpResponse(f"Hello from django app. DB: {db_name}")


urlpatterns = [
    path("", index),
]
