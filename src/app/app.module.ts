import {NgModule} from '@angular/core';
import {BrowserModule} from '@angular/platform-browser';

import {AppComponent} from './app.component';
import {ButtonModule} from 'primeng/button';
import {InputTextareaModule} from "primeng/inputtextarea";
import {RippleModule} from "primeng/ripple";
import {InputTextModule} from "primeng/inputtext";
import {PdfGenerateComponent} from './pdf-generate/pdf-generate.component';
import {FormsModule} from '@angular/forms';
import { RouterModule, Routes } from '@angular/router';
const routes: Routes = [
  {path: 'pdf-generate', component: PdfGenerateComponent}
];
@NgModule({
  declarations: [
    AppComponent,
    PdfGenerateComponent
  ],
  imports: [
    BrowserModule,
    ButtonModule,
    InputTextareaModule,
    RippleModule,
    InputTextModule,
    FormsModule,
    RouterModule.forRoot(routes)
  ],
  providers: [],
  bootstrap: [AppComponent],
  exports: [RouterModule]
})
export class AppModule { }
