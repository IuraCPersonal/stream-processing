# STREAM PROCESSING WITH ACTORS

## 📑 INTRODUCTION

### General

Compared to the previous Project, all weeks for this one aim to build upon the same application.
The goal is to finish the Project with a more or less functional stream processing system.
Since you will be working on a complex application, each presentation will now require you
present 2 diagrams: a `Message Flow Diagram` and a `Supervision Tree Diagram`. The Message
Flow Diagram describes the message exchange between actors of your system whereas the
Supervision Tree Diagram analyzes the monitor structures of your application.
Every task you work on should be easily verifiable. Your system should provide logs about
starting / stopping actors, auto-scaling / load balancing workers and printing processed tweets
on screen.

### About this Repository

This repository contains second homework assignment for the `PTR` course here at `TUM FCIM`.

All the solutions are written in `Elixir`.

## 🐱‍👓 HOW TO RUN

Start the Docker Container:

```
docker run --rm -it -p 4000:4000 alexburlacu/rtp-server:faf18x
```

Download all dependencies:

```
mix deps.get
```

Start the Stream Processing App:

```shell
mix run --no-halt
```

## 🎯 PROGRESS


|  Week No. | Status |
|-----------|--------|
| WEEK 01   | `DONE` |
| WEEK 02   | `DONE` |
| WEEK 03   | `DONE` |
| WEEK 04   | `DONE` |
| WEEK 05   | `NONE` |
| WEEK 06   | `NONE` |

## 📮 CONTACT

If you have any question, please contact me through email: `iurie.cius@isa.utm.md`.

