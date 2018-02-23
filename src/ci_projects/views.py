from django.shortcuts import render
from django.http import HttpResponse, JsonResponse
from .models import Build
from .utils import get_data


def home(request):
    return render(
        request, 'ci_projects/home.html'
    )


def data(request):
    return JsonResponse(get_data())
