grenze_cmd:
    type: command
    debug: false
    name: grenze
    usage: /grenze
    script:
    - inject permission_op
    - define name <context.args.get[1]||null>
    - if <[name]> == null:
        - narrate "<red>Name Fehlt: <yellow>/grenze <light_purple>NAME"
        - stop
    - if <server.has_flag[grenzen.<[name]>]>:
        - narrate "<red>Name <[name]> existiert bereits."
        - stop
    - note <player.we_selection> as:<[name]>
    - if !<context.args.get[2]||null> == null:
        - flag server grenzen.<[name]>:<map[warn/<context.args.get[2]>]>
    - else:
        - flag server grenzen.<[name]>


grenze_world:
    type: world
    debug: false
    events:
        on player enters cuboid:
        # - narrate <context.area.note_name>
        - if !<server.flag[grenzen].keys.contains[<context.area.note_name>]>:
            # - narrate "Keine Grenze"
            - stop
        # - if !<player.has_flag[grenzer]>:
        - flag <player> grenzer duration:2m
        - define defaultwarn "Achtung, du verlässt den sicheren Bereich!"
        - title subtitle:<[defaultwarn]>
        # - adjust <player> potion_effects:<list[BLINDNESS,255,40,false,true,false|NIGHT_VISION,255,40,false,true,false]>
        # - adjust <player> potion_effects:<list[LEVITATION,160,100,false,true,false>
        # - adjust <player> potion_effects:<list[LEVITATION,130,200,false,true,false|SLOW,255,200,false,true,false]>
        - define t 0
        - while <player.has_flag[grenzer]>:
            - narrate "step: <[t]>/10"
            - if <[t]> < 3:
                - adjust <player> potion_effects:<list[CONFUSION,<[t].mul_int[25]>,200,false,false,false|SLOW,3,200,false,false,false|HUNGER,100,200,false,false,false]>
                # - adjust <player> potion_effects:<list[CONFUSION,<[t].mul_int[25]>,200,false,false,false|SLOW,3,200,false,false,false|
            - else if <[t]> < 5:
                - adjust <player> potion_effects:<list[CONFUSION,<[t].mul_int[25]>,200,false,false,false|SLOW,3,200,false,false,false|POISON,100,200,false,false,false]>
            - else if <[t]> < 11:
                - adjust <player> potion_effects:<list[CONFUSION,<[t].mul_int[25]>,200,false,false,false|SLOW,3,200,false,false,false|POISON,150,200,false,false,false]>
            - else:
                - execute as_server "kill <player.name>"
                - stop
            - wait 2s
            - define t <[t].add_int[1]>
            # - flag <player> grenzer:<player.flag[grenzer].add_int[1]>
        # - adjust <player> potion_effects:<list[CONFUSION,10,200,false,true,false|SLOW,10,200,false,true,false]>
        # - wait 1s
        # - wait 1s
        # - adjust <player> potion_effects:<list[CONFUSION,150,200,false,true,false|SLOW,15,200,false,true,false|POISON,150,200,false,false,false]>
        # - wait 1s
        # - adjust <player> potion_effects:<list[CONFUSION,250,200,false,true,false|SLOW,255,200,false,true,false|POISON,250,200,false,false,false]>
        # - adjust <player> oxygen:2
        on player exits cuboid:
        # - announce "<dark_gray><player.name> left <context.area.note_name>"
        - if !<server.flag[grenzen].keys.contains[<context.area.note_name>]>:
            # - narrate "Keine Grenze"
            - stop
        - adjust <player> remove_effects
        - flag <player> grenzer:!
        on player death:
        - flag <player> grenzer:!
        after player death:
        - flag <player> grenzer:!
