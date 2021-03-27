sidebar_world:
    type: world
    events:
        # on player login:
        on player joins:
        - run update_player_sidebar def:<player>


sidebar_cmd:
    type: command
    usage: /sidebar
    debug: false
    description: update sidebar
    name: sidebar
    tab complete:
    - define args1 <list[update|an|aus]>
    - if !<[args1].contains[<context.args.get[1]>]>:
        - determine <[args1]>
    - else:
        - determine <server.online_players.parse[name].include[alle]>
    script:
    - inject permission_op
    - define args1 <list[update|an|aus]>
    - if !<[args1].contains[<context.args.get[1]>]>:
            - narrate <gray>-----------------------------
            - narrate "<yellow>/seitenleiste update <light_purple>(SPIELER)"
            - narrate "  <gray>- Updated die Seitenleiste"
            - narrate "<yellow>/seitenleiste an <light_purple>(SPIELER)"
            - narrate "  <gray>- Blendet Seitenleiste ein"
            - narrate "<yellow>/seitenleiste aus <light_purple>(SPIELER)"
            - narrate "  <gray>- Blendet Seitenleiste temporär aus"
            - narrate <gray>-----------------------------
            - stop
    - if <list[update|an].contains[<context.args.get[1]>]>:
        - if <context.args.get[2]||null> == alle:
            - narrate "<blue>TODO: Für alle Spieler zugleich"
        - define player <server.match_player[<context.args.get[2]>]||<player.name>>
        - run update_player_sidebar def:<player>
        - stop
    - else if <context.args.get[1]> == aus:
        - sidebar remove players:<list[<player>]>
        - stop


update_player_sidebar:
    type: task
    debug: false
    definitions: player
    script:
        - define title "<black><bold>HC Adventure"
        - define zeilen <list[hallo]>
        - if <[player].is_op>:
            - define menu_btn "<dark_red>[Admin]"
            - define zeilen <[zeilen].include[<[menu_btn].on_click[menu]>]>
            # - narrate <[menu_btn].on_click[menu]>
        - sidebar set title:<[title]> values:<[zeilen]> players:<[player]>
        # - sidebar