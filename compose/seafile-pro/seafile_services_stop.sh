#!/bin/sh

sv -w600 force-stop /etc/seafile/service/*
sv exit /etc/seafile/service/*
