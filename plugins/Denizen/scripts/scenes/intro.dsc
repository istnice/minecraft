intro_cmd:
    type: command
    name: intro
    usage: /intro
    script:
    - inject permission_op
    # - narrate "Intro :) / brunnen"
    - define npc <npc[368]>
    - spawn <[npc]> <player.location.add[3,0,-3]>
    - define bell <player.location.add[4,1,3]>
    # - adjust <[bell].add[1,0,0]> block_type:<material[oak_planks]>
    - adjust <[bell].add[0,-1,0]> block_type:oak_planks
    - adjust <[bell]> block_type:bell
    - adjust <[bell].add[0,-1,-1]> block_type:lever
    - wait 0.5s
    # - ~walk <[npc]> to:<[bell].add[0,-1,-1]> lookat:<player.location> speed:0.8
    - ~walk <[npc]> to:<[bell].add[0,-1,-1].center> lookat:<player.location> speed:0.8
    # - adjust <[npc]> velocity:<[bell].add[0,-1,-1].center.sub[<[npc].location>]>
    # - adjust <[npc]> move:<[bell].add[0,-1,-1].center>
    # .sub[<[npc].location>]>
    # - move <[npc]> <[bell].add[0,-1,-1].center.sub[<[npc].location>]>
    # - narrate "Look"
    - look <[npc]> <[bell].add[0,-1,-1]>
    - wait 1s
    # - narrate "Bing"
    - adjust <[npc]> interact_with:<[bell]>
    # - adjust <player> interact_with:<[bell]>
    - animate <[npc]> animation:ARM_SWING
    # - adjustblock <[bell]> activate
    - adjustblock <[bell].add[0,-1,-1]> switched:true
    # - adjustblock <[bell]> power
    - wait 1s
    - adjust <[bell].add[0,-1,0]> block_type:air
    - adjust <[bell]> block_type:air
    - adjust <[bell].add[0,-1,1]> block_type:air
    - adjust <[bell].add[0,-1,-1]> block_type:air
    - despawn <[npc]>

    # - wait 1s
    # - animate <[npc]> animation:START_USE_MAINHAND
