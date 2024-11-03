from django.urls import path
from . import views

urlpatterns = [
    path('api/test-data/', views.get_test_data, name='get-test-data'),
]
