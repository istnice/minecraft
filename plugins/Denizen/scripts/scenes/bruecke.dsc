bruecken_assi:
    type: assignment
    debug: false
    actions:
        on assignment:
        - trigger name:click state:true
        - sneak <npc> start fake
        - trigger name:proximity state:true radius:10
        - sneak <npc> start fake
        on click:
            - stop
        on enter proximity:
            - flag <player> brueckenwarnung:!
            - if <player.flag[ruf.zwergen]||0> < 100:
                - chat "<white>HALT! Du bist kein Zwerg, du hast hier nichts zu suchen.. Verschwinde."
            - else:
                - chat "Wilkommen Freund."
        on move proximity:
        - if <player.flag[ruf.zwergen]||0> < 100:
             - if <player.location.x> < <npc.location.x>:
                - if !<player.has_flag[brueckenwarnung]>:
                    # - playeffect effect:CLOUD at:<player.location.add[0,2.5,0]> quantity:1 offset:0
                    - chat "<red>Kehr um oder stirb!"
                    - flag <player> brueckenwarnung:true duration:5s
                - if <player.location.x> < <npc.location.x.sub_int[1]>:
                    - if !<player.has_flag[zielvon.bruecke]>:
                        - chat "<red>Erschießt den Eindringling!" targets:<npc[179]>
                        - flag <player> zielvon.bruecke:true duration:1m
        on exit proximity:
        # - narrate "player left"
        # - narrate "<npc.location.x.sub_int[4]>"
        - if <player.location.x> < <npc.location.x.sub_int[8]> && 100 > <player.flag[ruf.zwergen]||0>:
            # - if !<player.has_flag[brueckenkill]>:
                # - flag <player> brueckenkill:true duration:10
            # - execute as_server "kill <player.name>"
            - narrate "kill??"

fake_arrow:
    type: task
    script:
        - if <[hit_entities].size> > 0:
            - narrate "enteties hit" targets:<server.match_player[sarb0t]>
        - else:
            - narrate "no hit" targets:<server.match_player[sarb0t]>
        - remove <[shot_entities]>


check_target:
    type: procedure
    definitions: target|
    debug: false
    script:
        # - debug LOG "checking target"
        # - narrate "checking target"
        # - narrate "ziel: <[target]> flag: <[target].has_flag[zielvon.bruecke]>" targets:<server.match_player[sarb0t]>
        - if <[target].has_flag[zielvon.bruecke]>:
            # - narrate "ziel gefunden" targets:<server.match_player[sarb0t]>
            - determine true
        - determine false

bruecke_world:
    type: world
    events:
        on player death:
            - flag <player> zielvon:!