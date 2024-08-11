// Email obfuscator script 2.1 by Tim Williams, University of Arizona
// Random encryption key feature coded by Andrew Moulden
// This code is freeware provided these four comment lines remain intact
// A wizard to generate this code is at http://www.jottings.com/obfuscator/
function decode(coded, key){
  shift=coded.length
  link=""
  for (i=0; i<coded.length; i++) {
    if (key.indexOf(coded.charAt(i))==-1) {
      ltr = coded.charAt(i)
      link += (ltr)
    }
    else {     
      ltr = (key.indexOf(coded.charAt(i))-shift+key.length) % key.length
      link += (key.charAt(ltr))
    }
  }
  return link
}

!function() {
  for (var tags = document.querySelectorAll(".obfuscated"), i = 0; i < tags.length; i++) {
    var tag = tags[i]
    if (tag.getAttribute("coded") && tag.getAttribute("key")) {
      plain_text = decode(tag.getAttribute("coded"), tag.getAttribute("key"))
      if (tag.href) {
        tag.href = "mailto:" + plain_text
      } else {
        tag.innerHTML = plain_text
      }
      tag.removeAttribute("coded")
      tag.removeAttribute("key")
    }
  }
}()
