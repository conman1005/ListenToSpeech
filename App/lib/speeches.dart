/*
 *  Authours:           Conner Cullity and Jy
 *  Date last Revised:  2024-12-05
 *  Purpose:            This is an app that is meant to Listen to the User's Speech and save Transcripts. This app also utilizes ChatGPT to analyse the Speech.
 */


/// Speeches Class<br/> Used for turning Speeches Object to JSON
class Speeches {
  int id;
  String title;
  String content;

  Speeches(this.id, this.title, this.content);

    Map toJson() => {
      'id': id,
      'title': title,
      'content': content
    };
  }