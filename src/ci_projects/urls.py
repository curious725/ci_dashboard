from django.conf.urls import url

from . import views

app_name = 'ci_projects'
urlpatterns = [
    # ex: /ci/
    url(r'^$', views.home, name='home'),
]
