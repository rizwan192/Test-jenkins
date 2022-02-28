import {Component, OnInit} from '@angular/core';
import {ButtonModule} from 'primeng/button';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit {
  title = 'QuestionGenerate';
  question: any;
  option1: any;
  option2: any;
  option3: any;
  option4: any;
  questionValue: any = [];
  clickPdf: boolean = false;
  constructor() { }
  ngOnInit(): void {
    //dev
    //commit
  }

  saveQuestion($event: MouseEvent) {
    let questionVal = {
      'question': this.question,
      'option':{
        '1':this.option1,
        '2':this.option2,
        '3':this.option3,
        '4':this.option4
      }
    }
    this.questionValue.push(questionVal)
    console.log(this.questionValue)
  }

  generatePdf($event: MouseEvent) {
    this.clickPdf = true
  }
}
