bruecken_assi:
    type: assignment
    debug: false
    actions:
        on assignment:
        - trigger name:click state:true
        - sneak <npc> start fake
        - trigger name:proximity state:true radius:10
        - sneak <npc> start fake
        on spawn:
        - sneak <list[<npc>].include[<npc.name_hologram_npc||<list>>].include[<npc.hologram_npcs||<list>>]> start fake
        on despawn:
        - sneak <list[<npc>].include[<npc.name_hologram_npc||<list>>].include[<npc.hologram_npcs||<list>>]> stopfake
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
    # definitions: target
    debug: false
    script:
        # - debug LOG "checking target"
        # - narrate "checking target"
        # - narrate cont:<context>
        # - narrate "ziel: <[entity]> flag: <[entity].has_flag[zielvon.bruecke]>" targets:<server.match_player[MC_Sarbot]>
        - if <[entity].has_flag[zielvon.bruecke]>:
            - narrate "ziel gefunden" targets:<server.match_player[MC_Sarbot]>
            - determine true
        - determine false

bruecke_world:
    type: world
    events:
        on player death:
            - flag <player> zielvon:!