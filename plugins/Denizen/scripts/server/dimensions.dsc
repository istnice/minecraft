dungeon_cmd:
    type: command
    name: dimension
    usage: /dimension
    aliases:
        - dim
    description: manage dimensions
    tab complete:
    - define args1 <list[create|help|list|info|join|setup|reset|select]>
    - if !<[args1].contains[<context.args.get[1]||null>]>:
        - determine <[args1]>
    # - if <list[create].contains[<context.args.get[1]>]>:
    - define create_raw_args "create "
    - define setup_raw "setup "
    - define sel_raw "select "
    - if <context.raw_args.starts_with[<[create_raw_args]>]>:
        - if <context.args.get[2]||null> == null:
            - determine <list[NAME]>
        - else:
            - determine <list[COPYOF]>
    - else if <context.raw_args.starts_with[<[sel_raw]>]>:
        - determine <server.flag[dims].keys>
    - else if <context.raw_args.starts_with[<[setup_raw]>]>:
        - determine <list[name|tpin|tpout|start|finish|multiplayer]>
    script:
    - inject permission_op
    - if !<list[create|help|list|info|join|setup|reset|select].contains[<context.args.get[1]||null>]>:
        - narrate <gray>-----------------------------
        - narrate "<yellow>/dim list"
        - narrate "  <gray>- Listet alle künstlichen Dimensionen."
        - narrate "<yellow>/dim select"
        - narrate "  <gray>- Wählt ein Dungeon zum Bearbeiten aus."
        - narrate "<yellow>/dim info"
        - narrate "  <gray>- Zeigt Info zur ausgewählten Dimension und dessen Instanzen."
        - narrate "<yellow>/dim create <light_purple>ID"
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
        - narrate "<dark_purple>--- Dimension: <[dim_title]> ---"
        - narrate "<dark_gray>Original: <aqua><[dim_name]>"
        - narrate "<dark_gray>Instanzen: <aqua>TODO: flag instances"
        - narrate "<dark_gray>Start: <aqua><[start].simple.formatted||<red>missing>"
        - narrate "<dark_gray>Finish: <aqua><[finish].simple.formatted||<red>missing>"
        - narrate "<dark_gray>TPin: <aqua>box <[tpin].center.simple.formatted||<red>missing>"
        - narrate "<dark_gray>TPout: <aqua>box <[tpout].center.simple.formatted||<red>missing>"
        - narrate "<dark_purple>--------------"
        - stop

    # | reset
    - if <context.args.get[1]> == reset:
        - define <[dim_name]> <context.args.get[2]||<player.flag[selected_dim]>||null>
        - if <[dim_name]> == null:
            - narrate "<red>Fehler:<gray> Keine Dimension ausgewählt, benutze <yellow>/dim info <red>NAME <gray> oder wähle eine Dimesion aus (<yellow>/dim select <red>NAME<gray>)"
            - stop
        # TODO remove server flag
        # TODO destroy world?
        - narrate "(TODO)<gray>Dimension <aqua><[dim_name]> <gray>für <[player]> zurückgesetzt"



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
        - define dim_start <location[0,100,0,0,0,<[dim_name]>]>
        - define dim_finish <player.location>
        # notables for tpin and tpout has to be set (names are dim_tpin_NAME)
        # TODO check dimname exist in flag and in notables/world file -> warnings
        - define dim_data <map[name/<[dim_name]>|start/<[dim_start]>|finish/<[dim_finish]>]>
        - flag server dims.<[dim_name]>:<[dim_data]>
        - flag <player> selected_dim:<[dim_name]>
        - ~createworld <[dim_name]> copy_from:<[dim_copy]>
        - teleport <player> <[dim_start]>
        - stop

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
    debug: false
    definitions: player|dim_name
    script:
    - ratelimit <player> 5s
    - define dim_data <server.flag[dims.<[dim_name]>]>
    - debug log "<[player]> (<[player].gamemode>) wants to join <[dim_name]>"
    - define dim_start <[dim_data].get[start]>
    - if <player.gamemode> == creative:
        # - narrate "start pos: <[start]>"
        # - narrate <[dim_start]>
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
        - ~createworld <[ins_name]> copy_from:<[dim_name]>
        - ~createworld <[ins_name]>
        - wait 1s
        # - debug debug "flagging <world[<[ins_name]>]>"
        - flag <world[<[ins_name]>]> is_instance
        - define ins_start <[dim_start].with_world[<[ins_name]>]>
        # - narrate "<blue>dim_name: <[dim_name]>"
        # - narrate "<blue>ins_name: <[ins_name]>"
        # - narrate "<blue>dim_start: <[dim_start]>"
        # - narrate "<blue>ins_start: <[ins_start]>"
        - define dim_tpout <server.flag[dims.<[dim_name]>.tpout]>
        # - narrate "<dark_red>dim tpout: <[dim_tpout]>"
        - define ins_tpout <[dim_tpout].with_world[<[ins_name]>]>
        # - define ins_tpout <[dim_tpout].with_world[<[ins_name]>]>
        # - narrate "<dark_red>tmp tpout: <[ins_tpout]>"
        # - narrate "New world: <[ins_name]>"
        # - define ins_tpout <>
        - note <[ins_tpout]> as:tpout_<[ins_name]>
        # - narrate "<dark_green>NOTED: <[ins_tpout]>"
        # - narrate "world: <dark_purple><[ins_tpout].world>"
        # - narrate "<dark_blue>Teleport player to: <[dim_start]>"
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


# dim_world_proc:
#     type: task


dim_world:
    type: world
    events:
        on player enters cuboid:
        - if <context.area.note_name.starts_with[tpin_dim_]>:
            - define dim_name <context.area.note_name.substring[6]>
            - define player <player>
            - run dim_join_task def:<[player]>|<[dim_name]>
        - if <context.area.note_name.starts_with[tpout_dim_]>:
            - define dim_name <context.area.note_name.substring[7]>
            - define dim_name <[dim_name].split[-].get[1]>
            # - narrate "<black>tp out of dim: <[dim_name]>"
            - define finish <server.flag[dims.<[dim_name]>].get[finish]>
            - teleport <player> <[finish]>
            # - narrate "Teleport ausm Dungeon"
        on player death in:world_flagged:is_instance:
            - define dim_name <player.world.name.split[-].get[1]>
            - announce "<dark_red><player.name> ist in <[dim_name]> gestorben."
            # TODO: prevent real death (or give back respawnpoint) not compete with world 
            - teleport <player> <server.flag[dims.<[dim_name]>.start].with_world[<player.world>]>
            - determine cancelled