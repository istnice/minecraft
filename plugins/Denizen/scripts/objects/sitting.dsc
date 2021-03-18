# based on Icecapade's: https://paste.denizenscript.com/View/81550


stuhl_world:
    type: world
    debug: false
    events:
        # on player login:
        on player places block:
        - if <context.material.name.ends_with[wall_sign]>:
            # TODO: check block behind
            - define slock <context.location>
            - define face <context.material.direction>
            # - narrate <[face]>
            - if <[face]> == EAST:
                - define target <[slock].sub[1,0,0]>
            - else if <[face]> == WEST:
                - define target <[slock].add[1,0,0]>
            - else if <[face]> == NORTH:
                - define target <[slock].add[0,0,1]>
            - else:
                - define target <[slock].sub[0,0,1]>
            - if <[target].material.name.ends_with[stairs]>:
                - narrate "<yellow>/stuhl <aqua>mit Blick auf die Treppe um Stuhl zu erstellen."
        # - run update_player_sidebar def:<player>
        # on player right clicks *_stairs with:air:
        on player right clicks *_stairs:
        - if !<server.flag[stühle].contains[<context.location>]>:
            # - narrate "Kein Stuhl"
            - stop
        - if <player.has_flag[is_sit]> || <player.is_sneaking> || <context.location.material.half> == TOP:
            - stop
        - choose <context.location.material.direction>:
            - case NORTH:
                - spawn <context.location.add[0.5,-1.2,0.6]> armor_stand[visible=false;collidable=false;gravity=false] save:armor
                - look <entry[armor].spawned_entity> <context.location.add[0.5,0,1]>
            - case SOUTH:
                - spawn <context.location.add[0.5,-1.2,0.4]> armor_stand[visible=false;collidable=false;gravity=false] save:armor
                - look <entry[armor].spawned_entity> <context.location.add[0.5,0,-1]>
            - case WEST:
                - spawn <context.location.add[0.6,-1.2,0.5]> armor_stand[visible=false;collidable=false;gravity=false] save:armor
                - look <entry[armor].spawned_entity> <context.location.add[1,0,0.5]>
            - case EAST:
                - spawn <context.location.add[0.4,-1.2,0.5]> armor_stand[visible=false;collidable=false;gravity=false] save:armor
                - look <entry[armor].spawned_entity> <context.location.add[-1,0,0.5]>
        # - define armorstand <>
        - if !<server.has_flag[armorstands]>:
            - flag server armorstands:<map>
        - flag server armorstands:<server.flag[armorstands].with[<player.uuid>].as[<entry[armor].spawned_entity>]>
        - mount <player>|<entry[armor].spawned_entity>
        - flag player is_sit
        on player steers armor_stand:
        - if <context.dismount>:
            - define location <context.entity.location.add[0,2.2,0]>
            - inject unstuhl_task
            - teleport <[location]>
        on player quits flagged:is_sit:
        - inject unstuhl_task
        on player enters vehicle flagged:is_sit:
        - inject unstuhl_task
        on player teleports flagged:is_sit:
        - inject unstuhl_task
        on player dies flagged:is_sit:
        - inject unstuhl_task


stuhl_cmd:
    type: command
    name: stuhl
    usage: /stuhl
    description: erstellt stuhl aus treppe
    script:
    - define target <player.cursor_on>
    - if !<[target].material.name.ends_with[stairs]>:
        - narrate "<red>Funktioniert nur mit Treppen"
        - determine cancelled
    - if !<server.has_flag[stühle]>:
        - flag server stühle:<list>
    - flag server stühle:<server.flag[stühle].include[<[target]>]>
    - narrate "<green>Stuhl erstellt."


unstuhl_task:
    type: task
    debug: false
    script:
    - remove <server.flag[armorstands].get[<player.uuid>]>
    - flag <player> is_sit:!
    - flag server armorstands:<server.flag[armorstands].exclude[<player.uuid>]>