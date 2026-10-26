# ❤️ Heart Clinic

A pediatric clinic simulator made for the 2026 Congressional App Challenge.

Heart Clinic is a game designed to help children become more familiar with medical procedures. You run your own clinic, meet patients, ask questions, perform examinations, and make decisions, all under the supervision of a nurse who's there to help you along the way.

The goal is simple: make going to the doctor a little less scary.

## Gameplay

Each appointment follows a few steps:

1. **Meet your patient** and learn why they're visiting.
2. **Ask questions** to understand their symptoms.
3. **Perform examinations** using interactive medical tools.
4. **Review your findings** and decide what to do next.
5. **Get your rating** based on your decisions and how you treated the patient.

The game tracks each patient's comfort and trust throughout the appointment. There's no big red "WRONG!" when you make a mistake; instead, your nurse explains what happened and why another approach might work better.

## How It Works

Built with **Godot 4** and **GDScript**.

Most of the game runs through a reusable appointment system. Patients, questions, examinations, observations, and decisions are stored in Godot Resource files, allowing us to create new appointments without rewriting the core logic.

Each examination has its own interactive minigame, but everything connects back to the same appointment manager. The game also tracks patient states and calculates a final rating based on your actions.

## Running the Game

1. Clone or download this repository.
2. Open `project.godot` in Godot 4.
3. Run the project with F5.

## Future Plans

This is an early prototype, and there's still plenty we want to add:

- More patients, procedures, and medical tools
- Clinic customization and upgrades
- More detailed patient interactions
- Additional examination minigames
- A full clinic progression system

## Team

Created by **Ryan, Shaan, Sai, and Jacob** for the 2026 Congressional App Challenge (MD-06).
