from django.shortcuts import render
from django.http import HttpResponse, JsonResponse
from .models import Build
from .utils import get_data
from .serializers import BuildSerializer


def home(request):
    return render(
        request, 'ci_projects/home.html'
    )


def data(request):
    builds = Build.objects.all()
    serializer = BuildSerializer(builds, many=True)
    return JsonResponse(serializer.data, safe=False)
