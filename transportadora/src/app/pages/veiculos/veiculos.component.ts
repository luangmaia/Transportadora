import { Component, OnInit } from '@angular/core';
import { FormGroup, FormControl } from '@angular/forms';
import { VeiculosService } from './service/veiculos.service';

export interface Veiculo {
    peso: string;
    qtdVolumes: string;
    placa: string;
    modelo: string;
    capacidade: string;
}

const qtdPagina = 10;

@Component({
    selector: 'app-veiculos',
    templateUrl: './veiculos.component.html',
    styleUrls: ['./veiculos.component.css']
})
export class VeiculosComponent {
    displayedColumns: string[] = ['peso', 'qtd_volumes', 'placa', 'modelo', 'capacidade'];
    dataSource: Veiculo[] = [];
    buscaForm = new FormGroup({
        pesoMinimo: new FormControl(),
        pesoMaximo: new FormControl(),
        volumesMinimo: new FormControl(),
        volumesMaximo: new FormControl()
    });
    private pesoMinimo: number;
    private pesoMaximo: number;
    private qtdMin: number;
    private qtdMax: number;

    private offset = 0;

    get loading(): boolean {
        return this.veiculosService.loading;
    }

    constructor(private veiculosService: VeiculosService) { }

    buscar() {
        this.pesoMinimo = this.buscaForm.controls.pesoMinimo.value;
        this.pesoMaximo = this.buscaForm.controls.pesoMaximo.value;
        this.qtdMin = this.buscaForm.controls.volumesMinimo.value;
        this.qtdMax = this.buscaForm.controls.volumesMaximo.value;

        if (this.pesoMinimo == null ||
            this.pesoMaximo == null ||
            this.qtdMin == null ||
            this.qtdMax == null) {
            return;
        }

        this.veiculosService.getVeiculos(this.qtdMin, this.qtdMax, this.pesoMinimo, this.pesoMaximo, qtdPagina, this.offset)
            .then((response) => {
                if (response['data'] == null || response['data'].length === 0) {
                    this.offset = 0;
                    this.dataSource = [];
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
        return this.buscaForm.controls.pesoMinimo.value && this.buscaForm.controls.pesoMaximo.value &&
            this.buscaForm.controls.volumesMinimo.value && this.buscaForm.controls.volumesMaximo.value;
    }
}
