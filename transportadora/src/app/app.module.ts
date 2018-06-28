import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';


import { AppComponent } from './app.component';
import { HomeComponent } from './pages/home/home.component';
import { VeiculosComponent } from './pages/veiculos/veiculos.component';
import { ViagensComponent } from './pages/viagens/viagens.component';

import {
    MatToolbarModule,
    MatButtonModule,
    MatTableModule,
    MatFormFieldModule,
    MatInputModule,
    MatSnackBarModule,
    MatPaginatorModule
} from '@angular/material';
import { AppRoutingModule } from './/app-routing.module';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { HttpClientModule } from '@angular/common/http';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';

import { VeiculosService } from './pages/veiculos/service/veiculos.service';
import { ViagensService } from './pages/viagens/service/viagens.service';

@NgModule({
    declarations: [
        AppComponent,
        HomeComponent,
        VeiculosComponent,
        ViagensComponent
    ],
    imports: [
        BrowserModule,
        AppRoutingModule,
        MatToolbarModule,
        BrowserAnimationsModule,
        MatButtonModule,
        MatTableModule,
        MatFormFieldModule,
        MatInputModule,
        FormsModule,
        ReactiveFormsModule,
        HttpClientModule,
        MatProgressSpinnerModule,
        MatPaginatorModule
    ],
    providers: [
        ViagensService,
        VeiculosService
    ],
    bootstrap: [
        AppComponent
    ]
})
export class AppModule { }
