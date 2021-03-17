open_door_check:
    type: world
    debug: false
    events:
        # https://one.denizenscript.com/denizen/lngs/advanced script event matching
        on player right clicks *_trapdoor|*_door|lever|*_gate|dispenser|*dropper|*hopper|*chest|*button|*furnace:
        # on player right clicks *_door|*_trapdoor:
        - define door <context.location>
        - if <context.location.material.half> == TOP:
            - define door <context.location.add[0,-1,0]>
        # - narrate "FLAGS: <[door].list_flags>"
        - if <[door].has_flag[locked]>:
            - narrate "<gray>Abgeschlossen..."
            - determine cancelled
        # TODO: close door after x seconds
        - else if <[door].has_flag[req]>:
            - define druf <[door].flag[req.ruf]||null>
            - define pruf <player.flag[ruf.<[door].flag[req.gilde]>]||0>
            - if <[druf]> > <[pruf]> || <[druf]>==null:
                - narrate "<gray>Verschlossen! Erfordert: <[pruf]>/<[druf]> Ruf bei den <[door].flag[req.gilde]>"
                - determine cancelled
        - else if <[door].has_flag[key]>:
            # - narrate <[door].flag[key]>
            # - narrate <player.item_in_hand>
            - if <player.item_in_hand.display> != <[door].flag[key]>:
                - narrate "<gray>Verschlossen! Erfordert <[door].flag[key]> in der Hand."
                - determine cancelled
            - else:
                - narrate "<gray>Mit <player.item_in_hand.display> geöffnet."


lock_door_cmd:
    type: command
    name: schloss
    description: verschliesst Block
    usage: /schloss
    debug: true
    tab complete:
    - define args1 <list[auf|zu|ruf|flag|item|info]>
    - if !<[args1].contains[<context.args.get[1]||null>]>:
        - determine <[args1]>
    - else if <context.args.get[1]> == ruf:
        - if <context.args.get[3]||null> != null:
            - determine <list[MENGE]>
        - determine <list[soldaten|magier|handwerker]>
    - else if <context.args.get[1]> == flag:
        - determine <list[FLAG]>
    script:
    - if !<list[auf|zu|ruf|flag|item|info].contains[<context.args.get[1]||null>]>:
        - narrate <gray>-----------------------------
        - narrate "<yellow>/schloss zu"
        - narrate "  <gray>- Verschließt den Block"
        - narrate "<yellow>/schloss auf"
        - narrate "  <gray>- Entriegelt den Block"
        - narrate "<yellow>/schloss ruf <light_purple>GILDE RUF"
        - narrate "  <gray>- Mindest Ruf bei Gilde zum öffnen"
        - narrate "<yellow>/schloss flag <light_purple>FLAG"
        - narrate "  <gray>- <blue>TODO: <gray>Flag, die ein Spieler haben muss"
        - narrate "<yellow>/schloss item"
        - narrate "  <gray>- Legt schlüssel fest (Mainhand-Item, umbenannt)"
        - narrate <gray>-----------------------------
        - stop
    - define block <player.cursor_on>
    # Filter object (in block type list?)
    # Lever, Trapdoors, Doors, Fencegates, Buttons, chests(?)
    - if <[block].material.half> == TOP:
        # - narrate "<gray> automatisch auf unteren block korregiert"
        - define door <player.cursor_on.add[0,-1,0]>
    # - narrate "Block: <[door].material>"

    # LOCK
    - if <context.args.get[1]> == zu:
        - narrate "<green>Block verschlossen!"
        # - adjustblock <[door]> flag:locked:true
        - flag <[block]> locked:true

    - if <context.args.get[1]> == ruf:
        - define req <map[gilde/<context.args.get[2]>|ruf/<context.args.get[3]>]>
        - flag <[block]> req:<[req]>
        - narrate "<green>Zugriff für <context.args.get[2]> mit <context.args.get[3]> Ruf."

    - if <context.args.get[1]> == key:
        - flag <[block]> key:<player.item_in_hand.display>
        - narrate "<green>Block mit <player.item_in_hand.display> abgeschlossen!"

    # UNLOCK
    - else if <context.args.get[1]> == auf:
        - flag <[block]> locked:!
        - flag <[block]> req:!
        - flag <[block]> key:!
        - narrate "<green>Tür aufgeschlossen!"
