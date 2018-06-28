import { Component, OnInit } from '@angular/core';
import { FormGroup, FormControl } from '@angular/forms';
import { ViagensService } from './service/viagens.service';

export interface Viagem {
    cnh_motorista: string;
    cpf_cnpj_destinatario: string;
    cpf_motorista: string;
    nome_destinatario: string;
    nome_motorista: string;
}

const qtdPagina = 10;

@Component({
    selector: 'app-viagens',
    templateUrl: './viagens.component.html',
    styleUrls: ['./viagens.component.css']
})
export class ViagensComponent {
    displayedColumns: string[] = ['nome_destinatario', 'cpf_cnpj_destinatario', 'cnh_motorista', 'nome_motorista', 'cpf_motorista'];
    dataSource: Viagem[] = [];
    buscaForm = new FormGroup({
        nomeDestinatario: new FormControl()
    });
    readonly qtdPagina = qtdPagina;

    private offset = 0;
    private nomeDestinatario: string;

    get loading(): boolean {
        return this.viagensService.loading;
    }

    constructor(private viagensService: ViagensService) { }

    buscar() {
        this.nomeDestinatario = this.buscaForm.controls.nomeDestinatario.value;

        if (this.nomeDestinatario == null) {
            return;
        }

        this.viagensService.getViagensByNomeDestinatario(this.nomeDestinatario, qtdPagina, this.offset)
            .then((response) => {
                if (response['data'] == null || response['data'].length === 0) {
                    this.offset -= qtdPagina;
                } else {
                    this.dataSource = response['data'];
                }
            })
            .catch((error) => {
                console.error(error);
                this.offset = 0;
                this.dataSource = [];
            });
    }

    voltarPagina() {
        this.offset -= qtdPagina;

        if (this.offset < 0) {
            this.offset = 0;
        }

        this.buscar();
    }

    proximaPagina() {
        this.offset += qtdPagina;

        this.buscar();
    }

    todosCamposPreenchidos(): boolean {
        return this.buscaForm.controls.nomeDestinatario.value;
    }
}
