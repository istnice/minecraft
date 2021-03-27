gui_menu:
    type: inventory
    inventory: CHEST
    title: Klickz /
    size: 27
    slots:
    - [i_tp] [i_it] [i_items] [i_monster] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [i_rel] [] [] [] [] [] [] [] [i_close]


gui_menu_tp:
    type: inventory
    inventory: CHEST
    title: Klickz / Teleport
    size: 27
    slots:
    - [i_spawn] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [i_menu] [] [] [] [] [] [] [] [i_close]
    # Procedural items can be used to specify a list of ItemTags for the empty slots to be filled with.
    # Each item in the list represents the next available empty slot.
    # When the inventory has no more empty slots, it will discard any remaining items in the list.
    # A slot is considered empty when it has no value specified in the slots section.
    # If the slot is filled with air, it will no longer count as being empty.
    # | Most inventory scripts should exclude this key, but it may be useful in some cases.
    procedural items:
        - define list <list>
        - foreach <server.online_players>:
            - define item player_head[skull_skin=<[value].name>;display_name=<[value].name>].with[flag=pkey:value]
            - define list:->:<[item]>
        - define mapFlag <server.flag[POIS]>
        - foreach <[mapFlag].keys> as:poikey:
            # - narrate <[poikey]>
            - define item red_wool[display_name=<[poikey]>]
            - flag <[item]> anitemflag:yupp
            # - narrate <[item].flag[anitemflag]>
            - define list:->:<[item]>
            - flag <[item]> test:jo
        - determine <[list]>


gui_menu_items:
    type: inventory
    inventory: CHEST
    title: Klickz / Items
    size: 54
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [i_menu] [] [] [] [] [] [] [] [i_close]
    # TODO: pagination bei mehr als 45 items...
    procedural items:
    - define items <list>
    - foreach <server.scripts> as:s:
        # - narrate <[s].container_type>
        - if <[s].container_type> == ITEM:
            # - narrate "Item"
            - if <[s].name.starts_with[i_]>:
                # - narrate "valid item"
                # - define i <item[<[s].name>]||null>
                # - if !<[i]> == null:
                    # - narrate <[i].display>
                - define i <item[<[s].name>]>
                - if <[i].has_flag[preis]>:
                    - define items:->:<[i]>
    - determine <[items]>


gui_menu_monster:
    type: inventory
    inventory: CHEST
    title: Menu / Monster
    size: 54
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [i_menu] [] [] [] [] [] [] [] [i_close]
    # TODO: pagination bei mehr als 45 items...
    procedural items:
    - define items <list>
    - foreach <server.flag[monster].keys> as:type:
        - define item <item[monsterspawn_item]>
        - define display "Monster - <[type]>
        - adjust def:item display:<[display]>
        - adjust def:item flag:monstertype:<[type]>
        # - adjust def:item 
        - define items:->:<[item]>
    - determine <[items]>



gui_menu_it:
    type: inventory
    inventory: CHEST
    title: Klickz / Items
    size: 27
    slots:
    - [i_cmd] [i_barr] [i_dbg] [i_fra] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [i_menu] [] [] [] [] [] [] [] [i_close]


gui_menu_br:
    type: inventory
    inventory: CHEST
    title: Klickz / Brushes
    size: 27
    slots:
    - [i_br1] [i_br2] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [i_menu] [] [] [] [] [] [] [] [i_close]



gui_command:
    type: command
    description: öffnet inventory menü
    name: menu
    usage: /menu
    alias: gui
    script:
    - inject permission_op
    - inventory open d:gui_menu


gui_handler:
    type: world
    events:
        # menu
        on player clicks i_tp in gui_menu priority:2:
        - inventory close d:gui_menu
        - inventory open d:gui_menu_tp
        # TODO: unify und open unified inv based on flags
        on player clicks i_it in gui_menu priority:2:
        - inventory close d:gui_menu
        - inventory open d:gui_menu_it
        on player clicks i_items in gui_menu priority:2:
        - inventory close d:gui_menu
        - inventory open d:gui_menu_items
        on player clicks i_monster in gui_menu priority:2:
        - inventory close d:gui_menu
        - inventory open d:gui_menu_monster
        on player clicks i_close in inventory priority:2:
        - inventory close d:<context.inventory>
        on player clicks i_menu in inventory priority:2:
        - inventory close d:<context.inventory>
        - inventory open d:gui_menu

        # tp
        on player clicks i_spawn in gui_menu_tp priority:2:
        - teleport <player> <server.flag[pois.spawn]>
        on player clicks i_close in gui_menu_tp priority:2:
        - inventory close d:gui_menu_tp

        # it
        on player clicks i_cmd in gui_menu_it priority:2:
        - give command_block
        on player clicks i_barr in gui_menu_it priority:2:
        - give barrier
        on player clicks i_dbg in gui_menu_it priority:2:
        - give debug_stick
        on player clicks i_fra in gui_menu_it priority:2:
        # - define frame <item[item_frame]>
        - give <item[i_fra]>
        # --
        on player clicks i_menu in gui_menu_it priority:2:
        - inventory close d:gui_menu_it
        - inventory open d:gui_menu
        on player clicks i_close in gui_menu_it priority:2:
        - inventory close d:gui_menu_it
        # br
        on player clicks i_menu in gui_menu_br priority:2:
        - inventory close d:gui_menu_br
        - inventory open d:gui_menu
        on player clicks i_close in gui_menu_br priority:2:
        - inventory close d:gui_menu_br

        # disable default inventory actions
        on player clicks in gui_menu priority:50:
        - determine cancelled
        on player drags in gui_menu priority:50:
        - determine cancelled
        on player clicks in gui_menu_tp priority:50:
        # handle generics
        # - narrate <context.item>
        - if <context.item.material.name> == player_head:
            # - narrate <context.item.display>
            - teleport <player> <server.match_player[<context.item.display>].location>
        - determine cancelled
        on player drags in gui_menu_tp priority:50:
        - determine cancelled
        on player clicks in gui_menu_it priority:50:
        - determine cancelled
        on player drags in gui_menu_it priority:50:
        - determine cancelled


i_close:
    type: item
    material: barrier
    display name: Abbrechen


i_menu:
    type: item
    material: bookshelf
    display name: Hauptmenü

# TODO: 1 item template wiederverwenden? inventory links / paths in flags?
i_rel:
    type: item
    material: clock
    display name: Reload Denizen


i_tp:
    type: item
    material: compass
    display name: Teleport

i_it:
    type: item
    material: red_wool
    display name: Admintools

i_items:
    type: item
    material: green_wool
    display name: Items

i_monster:
    type: item
    material: wolf_spawn_egg
    display name: Spawn Monster

# locations
i_spawn:
    type: item
    material: oak_sapling
    display name: Spawn


# items
i_cmd:
    type: item
    material: command_block
    display name: Commandblock


i_barr:
    type: item
    material: barrier
    display name: Barrier


i_dbg:
    type: item
    material: debug_stick
    display name: Debugstick


i_fra:
    type: item
    material: item_frame
    display name: Invis Itemframe
    mechanisms:
        invisible: true


# brushes

i_br1:
    type: item
    material: arrow_of_night_vision
    display name: Beispiel Brush

i_br2:
    type: item
    material: arrow_of_leaping
    display name: Beispiel Brush

