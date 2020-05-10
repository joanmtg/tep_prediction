from django.shortcuts import render, redirect
from django.http import HttpResponse, JsonResponse
from django.contrib.auth import login, logout, authenticate
from django.contrib import messages

def login_view(request):

    if request.user.is_authenticated:
        return redirect("tep/")
    if request.POST:
        username = request.POST['username']
        password = request.POST['password']
        user = authenticate(request, username=username, password=password)
        if user is not None:
            login(request, user)
            return redirect("tep/")
        else:
            messages.error(request,"Usuario o Contraseña Incorrectos!")
            return render(request, "tep/login.html")
    else:
        logout(request)
        return render(request, "tep/login.html")


def logout_view(request):
    logout(request)
    return render(request, 'tep/index.html')