sidebar_world:
    type: world
    events:
        # on player login:
        on player joins:
        - run update_player_sidebar def:<player>


sidebar_cmd:
    type: command
    usage: /sidebar
    description: update sidebar
    name: sidebar
    script:
        - run update_player_sidebar def:<player>


update_player_sidebar:
    type: task
    definitions: player
    script:
        - define title "<black><bold>HC Adventure"
        - define zeilen <list[hallo]>
        - if <player.is_op>:
            - define menu_btn "<red>☞ Admin Menü"
            - define zeilen <[zeilen].include[<[menu_btn].on_click[menu]>]>
            - narrate <[menu_btn].on_click[menu]>
        - sidebar set title:<[title]> values:<[zeilen]>
        # - sidebar