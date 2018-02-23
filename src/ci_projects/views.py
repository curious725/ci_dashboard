from django.shortcuts import render
from django.http import HttpResponse, JsonResponse
from django.core import serializers


from .models import Build

from .utils import get_data


def home(request):
    return render(
        request, 'ci_projects/home.html'
    )


def data(request):
    return JsonResponse(get_data())


def data_stacked_bar(request):
    result = Build.prepare_data_stacked_bar()
    return HttpResponse(result)
