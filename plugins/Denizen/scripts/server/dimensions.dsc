dim_cmd:
    type: command
    debug: false
    name: dimension
    usage: /dimension
    aliases:
        - dim
    description: manage dimensions
    tab complete:
    - define args1 <list[create|help|list|info|join|setup|reset|select|remove|rem]>
    - if !<[args1].contains[<context.args.get[1]||null>]>:
        - determine <[args1]>
    # - if <list[create].contains[<context.args.get[1]>]>:
    - define create_raw_args "create "
    - define setup_raw "setup "
    - define sel_raw "select "
    - define space " "
    - if <context.raw_args.starts_with[<[create_raw_args]>]>:
        - define templates <list[superflat]>
        - if <context.args.get[2]||null> != null && <context.raw_args.ends_with[<[space]>]>:
            - determine <[templates]>
        - else if <context.args.get[3]||null> != null:
            - determine <[templates]>
        - if <context.args.get[2]||null> == null:
            - determine <list[ID]>
        - else:
            - determine <list[COPYOF]>
    - else if <context.raw_args.starts_with[<[sel_raw]>]>:
        - determine <server.flag[dims].keys>
    - else if <context.raw_args.starts_with[<[setup_raw]>]>:
        - determine <list[name|tpin|tpout|start|finish|multiplayer]>
    - else if <context.args.get[1]> == join:
        - determine <server.flag[dims].keys>
    - else if <list[remove|rem|delete|del].contains[<context.args.get[1]>]>:
        - determine <server.flag[dims].keys>
    script:
    - inject permission_op
    - if !<list[create|help|list|info|join|setup|reset|select|rem|delete|del|remove].contains[<context.args.get[1]||null>]>:
        - narrate <gray>-----------------------------
        - narrate "<yellow>/dim list"
        - narrate "  <gray>- Listet alle künstlichen Dimensionen."
        - narrate "<yellow>/dim select"
        - narrate "  <gray>- Wählt ein Dungeon zum Bearbeiten aus."
        - narrate "<yellow>/dim info"
        - narrate "  <gray>- Zeigt Info zur ausgewählten Dimension und dessen Instanzen."
        - narrate "<yellow>/dim create <light_purple>ID <light_purple>(TEMPLATE)"
        - narrate "  <gray>- Erstellt neue künstliche Dimension. ID = Einzigartiges Wort ohne Sonderzeichen sein."
        - narrate "<yellow>/dim reset <light_purple>(PLAYER)"
        - narrate "  <gray>- Löscht die Instanz (ID) der ausgewählten Dimension (Optional von anderen),"
        # - narrate "<yellow>/dim join <light_purple>NAME"
        # - narrate "  <gray>- tritt der dimension bei (als flag ohne tp)"
        - narrate <gray>-----------------------------
        - stop
    # | list
    - if <context.args.get[1]> == list:
        - narrate "<dark_blue>--- Dimensionen: ---"
        - narrate "<gray>Anklicken zum auswählen..."
        - foreach <server.flag[dims].keys> as:dim_name:
            - narrate "<aqua> <[dim_name].on_click[/dim select <[dim_name]>]>"
        - narrate "<dark_blue>----------- "
        - stop

    # | select
    - if <context.args.get[1]> == select:
        - define dim_name <context.args.get[2]||null>
        - if <[dim_name]> == null || !<server.has_flag[dims.<[dim_name]>]>:
            - narrate "<red>Dimension nicht gefunden."
            - stop
        - flag <player> selected_dim:<[dim_name]>
        - narrate "<dark_green><[dim_name]> ausgewählt."
        - stop

    # | info
    - if <context.args.get[1]> == info:
        - define dim_name <context.args.get[2]||null>
        - if <[dim_name]> == null:
            - define dim_name <player.flag[selected_dim]||null>
        - if <[dim_name]> == null:
            - narrate "<red>Fehler:<gray> Keine Dimension ausgewählt, benutze <yellow>/dim info <red>NAME <gray> oder wähle eine Dimesion aus (<yellow>/dim select <red>NAME<gray>)"
            - stop
        - define tpin <server.flag[dims.<[dim_name]>.tpin]||null>
        - define tpout <server.flag[dims.<[dim_name]>.tpout]||null>
        - define start <server.flag[dims.<[dim_name]>.start]||null>
        - define finish <server.flag[dims.<[dim_name]>.finish]||null>
        - define title <server.flag[dims.<[dim_name]>.title]||<[dim_name]>>
        - define inis <server.flag[dims.<[dim_name]>.instances]||<list[keine]>>
        - narrate "<dark_purple>--- Dimension: <[dim_title]> ---"
        - narrate "<dark_gray>Original: <aqua><[dim_name]>"
        - narrate "<dark_gray>Instanzen: <aqua><[inis].comma_separated>"
        - narrate "<dark_gray>Start: <aqua><[start].simple.formatted||<red>missing>"
        - narrate "<dark_gray>Finish: <aqua><[finish].simple.formatted||<red>missing>"
        - narrate "<dark_gray>TPin: <aqua>box <[tpin].center.simple.formatted||<red>missing>"
        - narrate "<dark_gray>TPout: <aqua>box <[tpout].center.simple.formatted||<red>missing>"
        - narrate "<dark_purple>--------------"
        - stop

    # | reset
    - if <context.args.get[1]> == reset:
        # - define sel
        - define dim_name <context.args.get[2]||<player.flag[selected_dim]||null>>
        # - narrate <green><[dim_name]>
        # - narrate <dark_purple><context.args.get[2]>
        - if <[dim_name]> == null:
            - narrate "<red>Fehler:<gray> Keine Dimension ausgewählt, benutze <yellow>/dim info <red>NAME <gray> oder wähle eine Dimesion aus (<yellow>/dim select <red>NAME<gray>)"
            - stop
        - narrate "<gray>Dimension <aqua><[dim_name]> <gray> wird zurückgesetzt. #TODO: tp player out"
        - run dim_remove_inst_task def:<[dim_name]>

    # | create
    - if <context.args.get[1]> == create:
        - narrate "Neue Dimension erstellen"
        - if <context.args.get[2]> == world:
            - narrate "<red>Uff das war knapp, da hättest du fast, die Welt gelöscht.."
            - stop
        - if <context.args.get[2].starts_with[dim_]>:
            - define dim_name <context.args.get[2]>
        - else:
            - define dim_name dim_<context.args.get[2]||unnamed>
        - if <server.has_flag[dims.<[dim_name]>]>:
            - narrate "<red>Dimension mit diesem Namen existiert bereits, abgebrochen.."
            - stop
        - define dim_copy <context.args.get[3]||superflat>
        - define templates <list[superflat]>
        - if !<[templates].contains[<[dim_copy]>]>:
            - define space " "
            - narrate "<red>Template existiert nicht.<gray> Mögliche templates sind: <[templates].comma_separated>"
        - define dim_start <location[0,100,0,0,0,<[dim_name]>]>
        - define dim_finish <player.location>
        # notables for tpin and tpout has to be set (names are dim_tpin_NAME)
        # TODO check dimname exist in flag and in notables/world file -> warnings
        - define dim_data <map[name/<[dim_name]>|start/<[dim_start]>|finish/<[dim_finish]>]>
        - if <player.we_selection||null> != null:
            - define dim_data <[dim_data].with[tpin].as[<player.we_selection>]>
            - note <player.we_selection> as:tpin_<[dim_name]>
        - flag server dims.<[dim_name]>:<[dim_data]>
        - flag <player> selected_dim:<[dim_name]>
        - ~createworld <[dim_name]> copy_from:<[dim_copy]>
        - teleport <player> <[dim_start]>
        - stop

    # | join
    - if <context.args.get[1]> == join:
        - define dim_name <context.args.get[2]||<player.flag[selected_dim]||null>>
        - if <[dim_name]> == null:
            - narrate "<red>Keine Dimension gewählt. <gray>Benutze <yellow>/dim join <light_purple>ID<gray> oder markiere erst eine Dimension mit <yellow>/dim select."
            - stop
        - run dim_join_task def:<player>|<[dim_name]>
        - stop

    # | leave

    # | remove
    - if <list[rem|remove].contains[<context.args.get[1]>]>:
        # - narrate "run rem"

        - if <context.args.get[3]||null> != sure:
            - run dim_remove_task def:<context.args.get[2]||null>|false
            - stop
        - narrate "running sure"
        - run dim_remove_task def:<context.args.get[2]>|true


    # | setup
    - if <context.args.get[1]> == setup:
        - if !<list[tpin|tpout|start|finish|multiplayer|maxplayer].contains[<context.args.get[2]>]>:
            - narrate <gray>-----------------------------
            - narrate "<yellow>/dim setup <light_purple>NAME"
            - narrate "  <gray>- Anzeigenamen für Dimension. Leerzeichen erlaubt ;)"
            - narrate "<yellow>/dim setup tpin"
            - narrate "  <gray>- Aktuelle WorldEdit selection (//pos1 - //pos2) als Eingangsportal"
            - narrate "<yellow>/dim setup tpout"
            - narrate "  <gray>- Aktuelle WorldEdit selection (IN DIM) als Ausgangsportal"
            - narrate "<yellow>/dim setup start"
            - narrate "  <gray>- Aktuelle Position (IN DIM) als Startpunkt"
            - narrate "<yellow>/dim setup finish"
            - narrate "  <gray>- Aktuelle Position (world) als Rückportpunkt"
            - narrate "<yellow>/dim setup multiplayer <light_purple>(on/off)"
            - narrate "  <gray>- Ohne Multiplayer bekommt jeder Spieler eine eigene Welt"
            - narrate "<yellow>/dim setup maxplayer <light_purple>ZAHL"
            - narrate "  <gray>- <blue>TODO:<gray> Maximale Spielerzahl für Multiplayerdimension"
            - narrate "<yellow>/dim setup maxdeath <light_purple>ANZAHL"
            - narrate "  <gray>- <blue>TODO:<gray> Kickt Spieler nach ANZAHL Toden (-1 für unendlich)"
            - narrate "<yellow>/dim setup spectate <light_purple>(on/off)"
            - narrate "  <gray>- <blue>TODO:<gray> Macht Spieler zu spectator (für videosequenzen)"
            # - narrate "<yellow>/dim setup timelock <light_purple>TIME)"
            # - narrate "  <gray>- -1 für day-night-cycle"
            - narrate <gray>-----------------------------
            - stop
        - if !<player.has_flag[selected_dim]>:
            - narrate "<red>Fehler:<gray> Keine Dimension ausgewählt. Versuche <yellow>/dim select <light_purple>NAME"
            - stop
        - define dim <player.flag[selected_dim]>
        - choose <context.args.get[2]>:
            - case tpin:
                - if <player.we_selection||null> == null:
                    - narrate "<red>Fehler:<gray> Keine WorldEdit Selection. Markiere Ecken mit <yellow>//pos1 <gray> und <yellow>//pos2<gray>."
                    - stop
                # TODO: check if player is in original world
                - note <player.we_selection> as:tpin_<[dim]>
                - flag server dims.<[dim]>.tpin:<player.we_selection>
                - narrate "<dark_green>Eingangsportal gesetzt."
            - case tpout:
                - if <player.we_selection||null> == null:
                    - narrate "<red>Fehler:<gray> Keine WorldEdit Selection. Markiere Ecken mit <yellow>//pos1 <gray> und <yellow>//pos2<gray>."
                    - stop
                # TODO: check if player is in original world
                - note <player.we_selection> as:tpout_<[dim]>
                - flag server dims.<[dim]>.tpout:<player.we_selection>
                - narrate "<dark_green>Ausgangsportal gesetzt."
            - case start:
                - flag server dims.<[dim]>.start:<player.location>
            - case finish:
                - flag server dims.<[dim]>.finish:<player.location>
            - case multiplayer:
                - define arg3 <context.args.get[3]||null>
                - if <[arg3]> == on:
                    - flag server dims.<[dim]>.multiplayer
                    - narrate "<gray>Multiplayer für Dimension <[dim]> aktiviert."
                - else if <[arg3]> == off:
                    - flag server dims.<[dim]>.multiplayer:!
                    - narrate "<gray>Multiplayer für Dimension <[dim]> deaktiviert."
                - else if <server.has_flag[dims.<[dim]>.multiplayer]>:
                    - flag server dims.<[dim]>.multiplayer:!
                    - narrate "<gray>Multiplayer für Dimension <[dim]> deaktiviert."
                - else:
                    - flag server dims.<[dim]>.multiplayer
                    - narrate "<gray>Multiplayer für Dimension <[dim]> aktiviert."
        - stop


dim_join_task:
    type: task
    debug: true
    definitions: player|dim_name
    script:
    - ratelimit <player> 5s
    - define dim_data <server.flag[dims.<[dim_name]>]>
    - debug log "<[player]> (<[player].gamemode>) wants to join <[dim_name]>"
    - define dim_start <[dim_data].get[start]>
    - if <player.gamemode> == creative:
        # - narrate "start pos: <[start]>"
        # - narrate <[dim_start]>
        - announce "<dark_green>Original Instanz laden: <[dim_name]>" to_ops
        - ~createworld <[dim_name]>
        # - narrate "<dark_blue>Teleport player (CREATIVE) to: <[dim_start]>"
        - teleport <player> <[dim_start]>
        - define warning "<red>Original: alle Änderungen hier sind permanent"
        - title subtitle:<[warning]>
        - narrate "<gray><player.name> betritt <[dim_name]> (<dark_red>Original<gray>)"
        # - narrate ""
    - else if <player.gamemode> == adventure:
        - if <server.has_flag[dims.<[dim_name]>.multiplayer]>:
            - define ins_name <[dim_name]>-multiplayer
            - define multiplayer true
        - else:
            - define ins_name <[dim_name]>-<player.uuid>
            - define multiplayer false
        # - narrate "<gray>Erstelle/Lade Welt: <[ins_name]>"
        # TODO: try to create world except load existing (id flags)
        # - narrate "<dark_gray>create world as copy from <[dim_name]>"
        - if <world[<[ins_name]>]||null> == null:
            - announce "<dark_green>Neue Instanz erstellen: <[ins_name]> copy von <[dim_name]>" to_ops
            - ~createworld <[ins_name]> copy_from:<[dim_name]>
            - flag <server> dims.<[dim_name]>.instances:->:<[ins_name]>
        - else:
            - announce "<dark_green>Alte Instanz laden: <[ins_name]>" to_ops
            - ~createworld <[ins_name]>

        - wait 1s
        - flag <world[<[ins_name]>]> is_instance
        - define ins_start <[dim_start].with_world[<[ins_name]>]>
        - define dim_tpout <server.flag[dims.<[dim_name]>.tpout]>
        - define ins_tpout <[dim_tpout].with_world[<[ins_name]>]>
        - note <[ins_tpout]> as:tpout_<[ins_name]>
        - teleport <player> <[ins_start]>
        - if <[multiplayer]>:
            - define warning "<dark_green>Du bist in einer Multiplayer Instanz"
        - else:
            - define warning "<dark_green>Du bist in einer Singleplayer Instanz"
        - title subtitle:<[warning]>
        # - narrate "Instanz: <[ins_name]>"
        - narrate "<gray><player.name> betritt <[ins_name]> (<gold>Instanz<gray>)"
    - else:
        - narrate "<red>Fehler: <gray>Dimensionnen können nur im Gamemode CREATIVE oder ADVENTURE betreten werden."


dim_exit_task:
    type: task
    debug: false
    definitions: player|dim_name
    script:
    - define finish <server.flag[dims.<[dim_name]>].get[finish]>
    - teleport <[player]> <[finish]>


dim_remove_task:
    type: task
    debug: true
    definitions: dim_name|sure
    script:
    - if !<player.is_op>:
        - narrate "<red>Keine Berechtigung!"
        - stop
    - if <[dim_name].to_lowercase> == world:
        - announce "<dark_red>[GEMELDET] <gray><player> hat versucht die welt zu löschen."
        - adjust <player> is_op:false
        - adjust <player> gamemode:adventure
        - teleport <player> <server.flag[pois.jail]>
        - stop
                
    - if !<[sure]||false>:
        - if !<server.has_flag[dims.<[dim_name]>]>:
            - narrate "<yellow>[Warnung] <gray>Dimension <[dim_name]> ist nicht als dimension gelistet, wenn du fortfährst, werden trotzdem Dateien auf dem Server gelöscht."
        - define sure_btn "<dark_blue>☞ Ja, löschen"
        - define sure_cmd "/dim remove <[dim_name]> sure"
        - define sure_btn <[sure_btn].on_click[<[sure_cmd]>]>
        - narrate "<dark_red>[Achtung] <gray>Bist du sicher, dass du die Welt <red><[dim_name]> <gray>mit allen Instanzen <red>unwiederruflich löschen<gray> willst? <[sure_btn]>"
        - stop
    - run dim_remove_inst_task def:<[dim_name]>
    - narrate "Lösche Dimension: <[dim_name]>"
    - adjust <world[<[dim_name]>]> destroy
    - note remove as:tpin_<[dim_name]>
    - note remove as:tpout_<[dim_name]>

    - flag server dims.<[dim_name]>:!
    - wait 1s
    - narrate "<dark_green>[FERTIG]<gray> Alle Instanzen von <[dim_name]> gelöscht."


dim_remove_inst_task:
    type: task
    debug: true
    definitions: dim_name
    script:
    - if !<server.has_flag[dims.<[dim_name]>.instances]>:
        - announce "<red>[Fehler] <gray>Keine Instanzen für <[dim_name]> gefunden."
        - stop
    - foreach <server.flag[dims.<[dim_name]>.instances]> as:ins_name:
        - narrate "Lösche Instanz: <[ins_name]||null>"
        - note remove as:tpout_<[ins_name]>
        - note remove as:tpin_<[ins_name]>
        - flag server dims.<[dim_name]>.instances:!
        - adjust <world[<[ins_name]>]> destroy


dim_world:
    type: world
    debug: false
    events:
        on server start:
        - foreach <server.flag[dims].keys> as:dim_name:
            - run dim_remove_inst_task def:<[dim_name]>

        on player enters cuboid:
        - if <context.area.note_name.starts_with[tpin_dim_]>:
            - define dim_name <context.area.note_name.substring[6]>
            # - define player <player>
            - run dim_join_task def:<player>|<[dim_name]>
        - if <context.area.note_name.starts_with[tpout_dim_]>:
            - define dim_name <context.area.note_name.substring[7].split[-].get[1]>
            - run dim_exit_task def:<player>|<[dim_name]>
            # - define dim_name <[dim_name]>
            # - narrate "Teleport ausm Dungeon"
        on player death in:world_flagged:is_instance:
            - define dim_name <player.world.name.split[-].get[1]>
            - announce "<dark_red><player.name> ist in <[dim_name]> gestorben."
            - wait 3s
            # TODO: prevent real death (or give back respawnpoint) not compete with world
            - teleport <player> <server.flag[dims.<[dim_name]>.start].with_world[<player.world>]>
            - determine cancelled
        