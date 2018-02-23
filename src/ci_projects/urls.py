from django.conf.urls import url

from . import views

app_name = 'ci_projects'
urlpatterns = [
    # ex: /ci/
    url(r'^$', views.home, name='home'),
    # ex: /data
    url(r'^data/$', views.data, name='data'),
    # ex: /data/stacked-bar
    url(r'^data/stacked-bar$', views.data_stacked_bar, name='stacked-bar'),
]
