dialog_assi:
    type: assignment
    debug: false
    actions:
        on assignment:
        - trigger name:click state:true
        - trigger name:chat state:true
        on spawn:
        - sneak <list[<npc>].include[<npc.name_hologram_npc||<list>>].include[<npc.hologram_npcs||<list>>]> start fake
        on despawn:
        - sneak <list[<npc>].include[<npc.name_hologram_npc||<list>>].include[<npc.hologram_npcs||<list>>]> stopfake
    interact scripts:
      - 1 dialog_interaction


dialog_interaction:
    type: interact
    steps:
      default:
        click trigger:
          script:
          - run locally hauptmenu_text

      hauptmenu:
        click trigger:
          script:
          - run locally hauptmenu_text
        chat trigger:
          1:
            trigger: /1/. Erzähl mir von dir.
            script:
            - run locally geschichte_text
          2:
            trigger: /2/. Ich will ein Abenteurer werden
            script:
            - run locally abenteuer_text
          3:
            trigger: /3/. Braucht ihr noch Baumeister?
            script:
            - run locally baumeister_text
          4:
            trigger: /4/. Sorry, muss los..
            script:
            - run locally abschied_text

      geschichte:
        click trigger:
          script:
          - run locally geschichte_text
        chat trigger:
          1:
            trigger: /1/ Deinen Namen werde ich mir merken. Ich freue mich darauf diese Unterhaltung eines Tages fortzusetzen!
            script:
            - run locally freunde_text
          2:
            trigger: /2/ Ich will ein Abenteurer werden.
            script:
            - run locally abenteuer_text
          3:
            trigger: /3/ Braucht ihr noch Baumeister?
            script:
            - run locally baumeister_text
          4:
            trigger: /4/ Interessant, jetzt muss ich aber wirklich weiter.
            script:
            - run locally abschied_text

      abenteuer:
        click trigger:
          script:
          - run locally abenteuer_text
        chat trigger:
          1:
            trigger: /1/ Braucht ihr denn noch Baumeister?
            script:
            - run locally baumeister_text
          2:
            trigger: /2/ Schade, ich bin dann mal weg...
            script:
            - run locally abschied_text

      baumeister:
        click trigger:
          script:
          - run locally baumeister_text
        chat trigger:
          1:
            trigger: /1/ Wo genau soll diese Sandbank sein?
            script:
            - run locally sandbank_text
          2:
            trigger: /2/ "Danke, ciao!"
            script:
            - run locally abschied_text




    hauptmenu_text:
    - chat "Hallo Fremder, was kann ich für dich tun?"
    - narrate "<blue>[ <element[1.].on_click[1].on_hover[Erzähl mir von dir.]> ]   [ <element[2.].on_click[2].on_hover[Ich will ein Abenteurer werden]> ]   [ <element[3.].on_click[3].on_hover[Braucht ihr noch Baumeister?]> ] [ <element[4.].on_click[4].on_hover[Sorry, muss los..]> ]<reset> "
    - zap hauptmenu

    geschichte_text:
    - chat "Ich bin hier einfach erschienen. Woher ich komme, oder wohin ich gehe, weiß ich nicht. Aber eins steht fest: Ich bin der erste hier, mit dem man sich vernünftig unterhalten kann."
    - narrate "<blue>[ <element[1.].on_click[1].on_hover[Deinen Namen werde ich mir merken. Ich freue mich darauf diese Unterhaltung eines Tages fortzusetzen!]> ]   [ <element[2.].on_click[2].on_hover[Ich will ein Abenteurer werden]> ]   [ <element[3.].on_click[3].on_hover[Braucht ihr noch Baumeister?]> ] [ <element[4.].on_click[4].on_hover[Interessant, jetzt muss ich aber wirklich weiter.]> ]<reset> "
    - zap geschichte

    abenteuer_text:
    - chat "Hier gibt es noch nicht viele Abenteuer zu erleben. Zieh hinaus in die Welt, dort gibt es noch viel zu erkunden. Wenn du eines Tages wiederkommst haben wir vielleicht die ein oder andere Aufgabe für dich."
    - narrate "<blue>[ <element[1.].on_click[1].on_hover[Braucht ihr denn noch Baumeister?]> ] [ <element[2.].on_click[2].on_hover[Schade, ich bin dann mal weg...]> ]<reset> "
    - zap abenteuer

    baumeister_text:
    - chat "Baumeister werden hier gebraucht. Sprich dich mit den anderen ab um beim Aufbau dieses Ortes zu helfen. Ich hoffe es wird schon bald ein lebendiger, schöner Ort entstehen. Ich habe von einer Sandbank gehört, auf der die Götter dir die Kraft des Baumeisters und die Kontrolle über das Wetter verleihen können. Sie liegt nördlich von hier. Aber bitte gehe sorgsam mit der Gabe um und verwende sie nur hier."
    - narrate "<blue>[ <element[1.].on_click[1].on_hover[Wo genau soll diese Sandbank sein?]> ] [ <element[2.].on_click[2].on_hover[Danke, ciao!]> ]<reset> "
    - zap baumeister

    freunde_text:
    - chat "Ich freu mich auch, bis dann.
    - zap default

    sandbank_text:
    - chat "-2236 80, falls dir die Zahlen etwas sagen.."
    - zap default


    abschied_text:
    - random:
      - chat "Ok, bis dann."
      - chat "Man sieht sich."
      - chat "Bis bald."
      - chat "Auf Wiedersehen."
      - chat "Tschau."
    - zap default

# data:
#   alias:
#     text: blablabla
#     answers:
#       - [id: 1, text: bla bla!, next: alias17]
#       - [id: 2, text: blub bla!, next: alias3]



