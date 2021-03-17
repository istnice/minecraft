rezeptionist_assi:
    type: assignment
    debug: false
    actions:
        on assignment:
        - trigger name:click state:true
        - sneak <npc> start fake


glocke_task:
    type: world
    debug: false
    events:
        after player right clicks bell:
            - if <context.location> != <location[-2276,81,214,world]>:
                - stop
            - define npc <npc[120]>
            - if <[npc].has_flag[busy]>:
                - narrate "<gray>Das geht gerade nicht.."
                - stop
            # duration in system time (d,h,m,s)
            - flag <[npc]> busy duration:2m
            - wait 1
            - narrate "<gray>Entfernte Stimme: <white>Moment ich komme sofort."
            - wait 1
            - switch <[npc].anchor[door]> open:on
            - wait 1
            - ~walk <[npc]> <[npc].anchor[step1]> radius:0
            - switch <[npc].anchor[trap]> open:on
            - wait 0.5
            - ~walk <[npc]> <[npc].anchor[step2]> radius:0
            - switch <[npc].anchor[door]> open:off
            - wait 0.5
            - ~walk <[npc]> <[npc].anchor[step3]> radius:0
            - switch <[npc].anchor[trap]> open:off
            - wait 0.5
            # - narrate "Bin da"
            - chat "Da bin ich, was kann ich für dich tun?" talkers:<[npc]> targets:<player>
            # check each 5s to finishing the queue
            - waituntil rate:5 !<[npc].has_flag[busy]>
            - chat "Ich muss wieder los, klingel wenn du mich brauchst." talkers:<[npc]> no_target range:3
            - inject rezeptionist_reset


rezeptionist_reset:
    type: task
    debug: false
    definitions: npc
    script:
        - switch <[npc].anchor[door]> open:off
        - switch <[npc].anchor[trap]> open:off
        - teleport <[npc]> <[npc].anchor[start]>
