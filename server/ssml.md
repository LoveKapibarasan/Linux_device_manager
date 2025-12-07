
# SSML (Speech Synthesis Markup Language)

* Example:

1. Voice Change
```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="en-US">
  <voice name="en-US-JennyNeural">
    Hello, I'm Jenny.
  </voice>
  <voice name="en-US-GuyNeural">
    And I'm Guy.
  </voice>
</speak>
```
2. Emotion
```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis"
       xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="en-US">
<voice name="en-US-JennyNeural">
    <mstts:express-as style="cheerful">
        I'm so happy today!
    </mstts:express-as>
    <mstts:express-as style="sad">
        But yesterday was difficult.
    </mstts:express-as>
</voice>
</speak>

```