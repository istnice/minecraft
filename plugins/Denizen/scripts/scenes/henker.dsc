henker_assi:
    type: assignment
    debug: false
    actions:
        on assignment:
        - trigger name:click state:true
        - sneak <npc> start fake
        - narrate "Ok wen kann ich hängen?"
        on click:
        - cooldown 100
        - if <player.flag[ruf.soldaten]||0> < 100:
            - random:
                - chat "Von dir lasse ich mir sicher nichts sagen!"
                - chat "Geht weiter.."
                - chat "Ich kenne euch nichtmal."
                - chat "Ich nehme nur Befehle von hochrangigen Soldaten an"
            - narrate "<gray>Ruf bei den Soldaten: <red><player.flag[ruf.soldaten]||0>/100"
            - stop
        - if <npc.flag[busy]||false>:
            - random:
                - chat "Siehst du nicht, das ich gerade beschäftigt bin?"
                - chat "Ey, ich bin gerade beschäftigt"
                - stop
                - stop
            - stop
        - flag <npc> busy:true
        - switch <npc.anchor[door1]> open:off
        - switch <npc.anchor[door2]> open:off
        # - define checks
        # - define check1-2314,86,211
        - define haenger <npc[119]>
        - chat "Ich geh einen Gefangenen holen"
        - ~walk <npc.anchor[step1]>
        - wait 1
        - ~walk <npc.anchor[step2]>
        # TODO open door
        # - adjustblock <npc.anchor[door1]> open:true
        - switch <npc.anchor[door1]> open:on
        - ~walk <npc.anchor[step3]>
        - wait 1
        - switch <npc.anchor[door2]> open:on
        - chat "Du da... Komm mit!" targets:<[haenger]>
        - wait 1
        - debug LOG  "bandit geh schritt 1"
        - ~walk <[haenger]> <[haenger].anchor[step1]>
        - wait 2
        - debug LOG "bandit geh zum galgen"
        # - narrate "<[haenger]>"
        # - action "walkto" <[haenger]> context:<npc.anchor[galgen]>
        - walk <npc.anchor[galgen]>
        # - wait 1
        - ~walk <[haenger]> <npc.anchor[galgen]>
        # - debug LOG "bandit geh rauf"
        - ~walk <[haenger]> <[haenger].anchor[haengt]>
        - debug LOG "tueren zu"
        - switch <npc.anchor[door1]> open:off
        - switch <npc.anchor[door2]> open:off
        - wait 1
        - debug LOG "HANG"
        - teleport <[haenger]> <[haenger].anchor[haengt]>
        - chat "Da baumelt er.. HAHAHA"
        - wait 3
        - walk <npc.anchor[start]>
        # - wait 30
        - wait 30
        - teleport <[haenger]> <[haenger].anchor[zelle]>
        - flag <npc> busy:false


verurteilter_walk:
    type: task
    script:
    - define bandit <npc[119]>
    - ~walk <[bandit]> <[bandit].anchor[step1]>


lauf_cmd:
    type: command
    name: blauf
    usage: /blauf
    description: renn
    script:
    - define bandit <npc[119]>
    - ~walk <[bandit]> <[bandit].anchor[step1]>
    - narrate <[bandit].anchor[step1]>
    # - run verurteilter_walk


verurteilter_assi:
    type: assignment
    debug: false
    actions:
        on assignment:
        - trigger name:click state:true
        - sneak <npc> start fake