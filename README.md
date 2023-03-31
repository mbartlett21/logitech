A program to make programming a Logitech mouse somewhat like qmk.



Setup
=====

1. Go to 'manage profiles' in G HUB.
2. Click the lua icon below your current profile.
3. Go to 'active lua script' and create a new script.
4. Copy and paste the entire script in.
5. Note that you will have to either have buttons unassigned in the main G HUB
   interface or in the Lua script. I have lmb, mmb and rmb assigned in G HUB,
   and the rest assigned through the script.



Configuring
===========

You can modify the section between `-- begin setup` and `-- end setup` to change
the layers (`clickmaps`). The first layer is the default layer, and is always
active.

`______` makes that button fall-through to the next active layer (goes from high to low).

`MB_NON` makes that button inactive.

`MO(x)` switches to that layer momentarily (the other layer needs to have the
corresponding key set to `______`)

`TO(x)` enables the target layer and disables all other layers (apart from the default one).

`TG(x)` toggles layer `x`.

Shortcuts are done using `{ ty = 'shortcut', shortcut, keys, and, clicks, here }`

For keycodes, refer to the G hub lua api manual that the software provides (Script -> Scripting API)



Contributing, etc
=================

Note that contributions are not accepted, and support is not provided.
